class StockMovement < ApplicationRecord
  belongs_to :product, optional: true
  belongs_to :product_variant, optional: true
  belongs_to :order, optional: true

  validates :quantity, numericality: { only_integer: true, other_than: 0 }
  validates :movement_type, :reason, presence: true
  validate :has_one_stock_target

  private

  def has_one_stock_target
    errors.add(:base, "Informe o produto ou a variação do movimento.") if product.blank? && product_variant.blank?
    errors.add(:base, "Informe apenas produto ou variação no movimento.") if product.present? && product_variant.present?
  end
end
