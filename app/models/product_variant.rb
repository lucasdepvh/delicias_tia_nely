class ProductVariant < ApplicationRecord
  belongs_to :product

  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :quantity, :low_stock_threshold, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }

  def effective_price
    price || product.price
  end

  def available?
    active? && product.active? && quantity.positive?
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[active name price product_id quantity]
  end
end
