class Product < ApplicationRecord
  belongs_to :category
  has_many :product_variants, dependent: :restrict_with_error
  has_many :product_images, dependent: :restrict_with_error
  has_one_attached :main_image

  validates :name, :slug, presence: true
  validates :slug, uniqueness: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, :low_stock_threshold, :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :main_image_is_valid
  validate :active_product_has_positive_price

  before_validation :generate_slug, on: :create

  scope :display_order, -> { order(:position, :name) }
  scope :active, -> { where(active: true) }

  def available?
    active? && (!track_inventory? || quantity.positive? || product_variants.where(active: true).where("quantity > 0").exists?)
  end

  def main_image_attached?
    main_image.attached?
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[active category_id featured name position price slug track_inventory]
  end

  private

  def generate_slug
    self.slug = name.to_s.parameterize if slug.blank? && name.present?
  end

  def active_product_has_positive_price
    errors.add(:price, "deve ser maior que zero para produto ativo") if active? && price.to_d <= 0
  end

  def main_image_is_valid
    return unless main_image.attached?

    unless main_image.blob.content_type.in?(%w[image/jpeg image/png image/webp])
      errors.add(:main_image, "deve ser PNG, JPEG ou WEBP")
    end
    errors.add(:main_image, "deve ter no máximo 5 MB") if main_image.blob.byte_size > 5.megabytes
  end
end
