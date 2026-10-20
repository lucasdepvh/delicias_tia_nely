class Order < ApplicationRecord
  belongs_to :customer
  belongs_to :delivery_area, optional: true
  belongs_to :discount, optional: true
  belongs_to :promotion, optional: true
  has_many :order_items, dependent: :restrict_with_error
  has_many :stock_movements, dependent: :restrict_with_error
  has_one :automatic_financial_entry, -> { where(automatic: true) }, class_name: "FinancialEntry", dependent: :restrict_with_error

  enum :status, { pending: "pending", confirmed: "confirmed", preparing: "preparing", ready: "ready", out_for_delivery: "out_for_delivery", delivered: "delivered", cancelled: "cancelled" }
  enum :fulfillment_method, { pickup: "pickup", delivery: "delivery" }, validate: true
  enum :payment_method, { pix: "pix", card: "card", cash: "cash", card_delivery: "card_delivery", card_pickup: "card_pickup", transfer: "transfer", other: "other" }, validate: true

  PAYMENT_LABELS = { "pix" => "Pix", "card" => "Cartão", "cash" => "Dinheiro", "card_delivery" => "Cartão na entrega", "card_pickup" => "Cartão na retirada", "transfer" => "Transferência", "other" => "Outro" }.freeze

  def payment_label
    PAYMENT_LABELS[payment_method]
  end

  def transition_to!(new_status)
    new_status = new_status.to_s
    raise ArgumentError, "Escolha um status de pedido válido." unless self.class.statuses.key?(new_status)

    with_lock do
      if new_status == "cancelled"
        restore_stock! if stock_deducted?
      elsif stock_consuming_status?(new_status) && !stock_deducted?
        deduct_stock!
      end

      update!(status: new_status)
      synchronize_financial_entry!(new_status)
    end
  end

  validates :number, presence: true, uniqueness: true
  validates :subtotal, :delivery_fee, :discount_amount, :total, numericality: { greater_than_or_equal_to: 0 }
  validates :payment_method, presence: true

  def status_label
    { "pending" => "Aguardando confirmação", "confirmed" => "Confirmado", "preparing" => "Em preparo", "ready" => "Pronto", "out_for_delivery" => "Saiu para entrega", "delivered" => "Entregue", "cancelled" => "Cancelado" }.fetch(status)
  end

  private

  def stock_consuming_status?(value)
    %w[confirmed preparing ready out_for_delivery delivered].include?(value)
  end

  def stock_demands
    demands = Hash.new(0)

    order_items.includes(:product, :product_variant).each do |item|
      next if item.promotion_gift? && item.product.nil?

      if item.product_variant
        variant = item.product_variant
        raise ArgumentError, "Um item do pedido não tem produto ativo para baixa de estoque." unless variant.active? && variant.product.active?

        demands[[ :variant, variant.id ]] += item.quantity
      elsif item.product&.track_inventory?
        raise ArgumentError, "Um item do pedido não está ativo para baixa de estoque." unless item.product.active?

        demands[[ :product, item.product_id ]] += item.quantity
      elsif item.product.nil?
        raise ArgumentError, "Um item do pedido não tem produto definido."
      end
    end

    demands
  end

  def locked_stock_targets(demands)
    products = Product.where(id: demands.filter_map { |(type, id), _quantity| id if type == :product }).order(:id).lock.to_a
    variants = ProductVariant.includes(:product).where(id: demands.filter_map { |(type, id), _quantity| id if type == :variant }).order(:id).lock.to_a
    targets = products.to_h { |product| [[ :product, product.id ], product] }
    targets.merge!(variants.to_h { |variant| [[ :variant, variant.id ], variant] })
    raise ArgumentError, "Um item do pedido não está mais disponível para baixa de estoque." unless targets.size == demands.size

    targets
  end

  def deduct_stock!
    demands = stock_demands
    targets = locked_stock_targets(demands)

    demands.each do |key, quantity|
      target = targets.fetch(key)
      raise ArgumentError, "Estoque insuficiente para confirmar este pedido." if target.quantity < quantity
    end

    demands.each do |key, quantity|
      target = targets.fetch(key)
      target.update!(quantity: target.quantity - quantity)
      stock_target = key.first == :product ? { product: target } : { product_variant: target }
      stock_movements.create!(stock_target.merge(
        quantity: -quantity,
        movement_type: "sale",
        reason: "Baixa pelo pedido #{number}"
      ))
    end
    update!(stock_deducted: true)
  end

  def restore_stock!
    demands = stock_demands
    targets = locked_stock_targets(demands)

    demands.each do |key, quantity|
      target = targets.fetch(key)
      target.update!(quantity: target.quantity + quantity)
      stock_target = key.first == :product ? { product: target } : { product_variant: target }
      stock_movements.create!(stock_target.merge(
        quantity: quantity,
        movement_type: "restoration",
        reason: "Restauração pelo cancelamento do pedido #{number}"
      ))
    end
    update!(stock_deducted: false)
  end

  def synchronize_financial_entry!(new_status)
    attributes = case new_status
    when "delivered"
      { status: "paid", paid_at: Date.current }
    when "cancelled"
      { status: "cancelled", paid_at: nil }
    else
      { status: "pending", paid_at: nil }
    end
    automatic_financial_entry.update!(attributes)
  end
end
