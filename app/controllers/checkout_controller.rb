class CheckoutController < PublicController
  PAYMENT_METHODS = %w[pix card cash card_delivery card_pickup transfer other].freeze
  DELIVERY_FIELDS = %i[zip_code street number neighborhood city state].freeze

  before_action :require_accepting_orders!

  def new
    @cart = current_cart
    redirect_to carrinho_path, alert: "Seu carrinho está vazio." and return if @cart.empty?
    @order = Order.new(fulfillment_method: "pickup", payment_method: "pix")
    @customer = Customer.new
  end

  def create
    @cart = current_cart
    @order = Order.new(checkout_params)
    @customer = Customer.new(customer_params)
    validate_checkout
    if @order.errors.any? || @customer.errors.any?
      render :new, status: :unprocessable_entity and return
    end

    Order.transaction do
      @customer = Customer.find_or_initialize_by(phone: @customer.phone.to_s.gsub(/\D/, ""))
      @customer.assign_attributes(customer_params)
      @customer.save!
      @order.customer = @customer
      @order.number = generate_order_number
      @order.status = "pending"
      @order.stock_deducted = false
      @order.save!
      @cart.items.each do |item|
        @order.order_items.create!(product: item.product, product_variant: item.variant, product_name: item.name, quantity: item.quantity, unit_price: item.unit_price, total: item.total)
      end
      FinancialEntry.create!(order: @order, entry_type: "income", status: "pending", automatic: true, description: "Pedido #{@order.number}", amount: @order.total, due_date: Date.current)
    end
    session[:order_numbers] = Array(session[:order_numbers]) << @order.number
    current_cart.clear
    redirect_to whatsapp_url_for(@order), allow_other_host: true
  rescue ActiveRecord::RecordInvalid
    @order.errors.add(:base, "Não foi possível registrar o pedido. Revise os dados e tente novamente.")
    render :new, status: :unprocessable_entity
  end

  private

  def validate_checkout
    @order.fulfillment_method = "pickup" unless %w[pickup delivery].include?(@order.fulfillment_method)
    @order.payment_method = "pix" if @order.payment_method.blank?
    @order.errors.add(:payment_method, "não é válido") unless PAYMENT_METHODS.include?(@order.payment_method)
    @order.errors.add(:base, "Seu carrinho está vazio ou contém itens indisponíveis.") if @cart.empty? || @cart.quantity != Array(session[:cart_items]).sum { |_key, entry| entry["quantity"].to_i }
    @order.errors.add(:base, "O pedido mínimo é de #{helpers.format_brl(StoreSetting.current.effective_minimum_order_value)}.") if @cart.subtotal < StoreSetting.current.effective_minimum_order_value
    if @order.delivery?
      DELIVERY_FIELDS.each { |field| @customer.errors.add(field, "não pode ficar em branco") if @customer.public_send(field).blank? }
      @order.delivery_fee = StoreSetting.current.default_delivery_fee
      @order.delivery_address = [ @customer.street, @customer.number, @customer.neighborhood, @customer.city, @customer.state, @customer.zip_code, @customer.complement.presence, @customer.reference.presence ].compact.join(", ")
    else
      @order.delivery_fee = 0
      @order.delivery_address = nil
    end
    @order.subtotal = @cart.subtotal
    @order.discount_amount = 0
    @order.total = @order.subtotal + @order.delivery_fee
    @order.errors.add(:change_for, "só pode ser informado para pagamento em dinheiro") if @order.change_for.present? && !@order.cash?
  end

  def customer_params
    params.require(:customer).permit(:name, :phone, :email, :zip_code, :street, :number, :neighborhood, :city, :state, :complement, :reference)
  end

  def checkout_params
    params.require(:order).permit(:fulfillment_method, :payment_method, :change_for, :notes)
  end

  def generate_order_number
    loop do
      number = "#{Time.zone.today.strftime('%Y%m%d')}-#{SecureRandom.hex(3).upcase}"
      return number unless Order.exists?(number: number)
    end
  end

  def whatsapp_url_for(order)
    setting = StoreSetting.current
    lines = [ setting.order_message.presence || "Olá! Gostaria de confirmar este pedido.", "Pedido: #{order.number}", "Cliente: #{order.customer.name} — #{order.customer.phone}", "", "Itens:" ]
    order.order_items.each { |item| lines << "#{item.quantity}x #{item.product_name} — #{helpers.format_brl(item.unit_price)} = #{helpers.format_brl(item.total)}" }
    lines += [ "", "Subtotal: #{helpers.format_brl(order.subtotal)}", "Entrega: #{helpers.format_brl(order.delivery_fee)}", "Total: #{helpers.format_brl(order.total)}", "Recebimento: #{order.delivery? ? 'Entrega' : 'Retirada'}", "Pagamento: #{order.payment_method.humanize}" ]
    lines << "Endereço: #{order.delivery_address}" if order.delivery?
    lines << "Observações: #{order.notes}" if order.notes.present?
    "https://wa.me/#{setting.whatsapp_number.to_s.gsub(/\D/, '')}?text=#{ERB::Util.url_encode(lines.join("\n"))}"
  end
end
