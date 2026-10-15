class Category < ApplicationRecord
  has_many :products, dependent: :restrict_with_error

  validates :name, :slug, presence: true
  validates :slug, uniqueness: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_validation :generate_slug, on: :create

  scope :display_order, -> { order(:position, :name) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[active name position slug]
  end

  private

  def generate_slug
    self.slug = name.to_s.parameterize if slug.blank? && name.present?
  end
end
