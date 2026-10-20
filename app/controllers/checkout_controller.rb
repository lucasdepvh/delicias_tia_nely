class CheckoutController < PublicController
  DELIVERY_FIELDS = %i[zip_code street number neighborhood city state].freeze
  before_action :require_accepting_orders!

  def new
    @cart = current_cart
    @cart.validated_items!
    @order = Order.new(fulfillment_method: "pickup", payment_method: "pix")
    @customer = Customer.new
  rescue ArgumentError => e
    redirect_to carrinho_path, alert: e.message
  end

  def create
    @cart = current_cart
    @order = Order.new(checkout_params)
    @customer = Customer.find_or_initialize_by(phone: customer_params[:phone].to_s.gsub(/\D/, ""))
    @customer.assign_attributes(customer_params)

    Order.transaction do
      items = @cart.validated_items!
      @customer.valid?
      validate_checkout(items)
      if @order.errors.any? || @customer.errors.any?
        render :new, status: :unprocessable_entity
        return
      end
      @customer.save!
      @order.customer = @customer
      @order.number = "#{Time.zone.today.strftime('%Y%m%d')}-#{SecureRandom.hex(6).upcase}"
      @order.status = "pending"
      @order.stock_deducted = false
      @order.save!
      items.each do |item|
        @order.order_items.create!(product: item.product, product_variant: item.variant, product_name: item.name,
                                  quantity: item.quantity, unit_price: item.unit_price, total: item.total)
      end
      FinancialEntry.create!(order: @order, entry_type: "income", status: "pending", automatic: true,
                             description: "Pedido #{@order.number}", amount: @order.total, due_date: Date.current)
    end
    session[:order_numbers] = (Array(session[:order_numbers]) << @order.number).last(20)
    @cart.clear
    redirect_to helpers.whatsapp_url_for(@order), allow_other_host: true, status: :see_other
  rescue ArgumentError => e
    @order.errors.add(:base, e.message)
    render :new, status: :unprocessable_entity
  rescue ActiveRecord::RecordInvalid
    @order.errors.add(:base, "Não foi possível registrar o pedido. Revise os dados e tente novamente.")
    render :new, status: :unprocessable_entity
  end

  def delivery_quote
    area = DeliveryArea.for_neighborhood(params[:neighborhood])
    fee = area&.fee || StoreSetting.current.default_delivery_fee
    render json: { fee: fee.to_s, estimated_time: area&.estimated_time,
                   message: area ? "Entrega na área #{area.name}." : "Sem área cadastrada para o bairro: aplicada a taxa padrão." }
  end

  private

  def validate_checkout(items)
    @order.errors.add(:base, "Escolha uma modalidade de recebimento válida.") unless Order.fulfillment_methods.key?(@order.fulfillment_method)
    @order.errors.add(:base, "Escolha uma forma de pagamento válida.") unless Order.payment_methods.key?(@order.payment_method)
    setting = StoreSetting.current
    @order.subtotal = items.sum(&:total)
    if @order.subtotal < setting.effective_minimum_order_value
      @order.errors.add(:base, "O pedido mínimo é de #{helpers.format_brl(setting.effective_minimum_order_value)} antes do frete.")
    end
    @order.delivery_fee = 0
    if @order.delivery?
      DELIVERY_FIELDS.each { |field| @customer.errors.add(field, "não pode ficar em branco") if @customer.public_send(field).blank? }
      @customer.errors.add(:zip_code, "deve conter 8 dígitos") unless @customer.zip_code.to_s.gsub(/\D/, "").match?(/\A\d{8}\z/)
      @customer.errors.add(:state, "deve conter a sigla da UF") unless @customer.state.to_s.match?(/\A[A-Za-z]{2}\z/)
      @order.delivery_area = DeliveryArea.for_neighborhood(@customer.neighborhood)
      @order.delivery_fee = @order.delivery_area&.fee || setting.default_delivery_fee
      @order.delivery_address = DELIVERY_FIELDS.map { |field| @customer.public_send(field) }.push(@customer.complement.presence, @customer.reference.presence).compact.join(", ")
    end
    @order.discount_amount = 0
    @order.total = @order.subtotal + @order.delivery_fee
    if checkout_params[:change_for].present?
      @order.errors.add(:base, "Troco só pode ser informado para pagamento em dinheiro.") unless @order.cash?
      amount = BigDecimal(checkout_params[:change_for].to_s, exception: false)
      unless amount&.finite? && amount >= @order.total
        @order.errors.add(:base, "O valor para troco deve ser válido e maior ou igual ao total.")
      end
    end
  end

  def customer_params
    params.fetch(:customer, ActionController::Parameters.new).permit(:name, :phone, :email, :zip_code, :street, :number, :neighborhood, :city, :state, :complement, :reference)
  end

  def checkout_params
    params.fetch(:order, ActionController::Parameters.new).permit(:fulfillment_method, :payment_method, :change_for, :notes)
  end
end
