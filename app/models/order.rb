class Order < ApplicationRecord
  belongs_to :customer
  belongs_to :delivery_area, optional: true
  belongs_to :discount, optional: true
  belongs_to :promotion, optional: true
  has_many :order_items, dependent: :restrict_with_error

  enum :status, { pending: "pending", confirmed: "confirmed", preparing: "preparing", ready: "ready", out_for_delivery: "out_for_delivery", delivered: "delivered", cancelled: "cancelled" }
  enum :fulfillment_method, { pickup: "pickup", delivery: "delivery" }
  enum :payment_method, { pix: "pix", card: "card", cash: "cash", card_delivery: "card_delivery", card_pickup: "card_pickup", transfer: "transfer", other: "other" }

  validates :number, presence: true, uniqueness: true
  validates :subtotal, :delivery_fee, :discount_amount, :total, numericality: { greater_than_or_equal_to: 0 }
  validates :payment_method, presence: true

  def status_label
    { "pending" => "Aguardando confirmação", "confirmed" => "Confirmado", "preparing" => "Em preparo", "ready" => "Pronto", "out_for_delivery" => "Saiu para entrega", "delivered" => "Entregue", "cancelled" => "Cancelado" }.fetch(status)
  end
end
