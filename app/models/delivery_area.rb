class DeliveryArea < ApplicationRecord
  validates :name, :slug, presence: true
  validates :fee, numericality: { greater_than_or_equal_to: 0 }

  def self.for_neighborhood(neighborhood)
    query = neighborhood.to_s.parameterize(separator: " ")
    return if query.blank?

    where(active: true).order(:name).detect do |area|
      name = area.name.parameterize(separator: " ")
      name.present? && (name.include?(query) || query.include?(name))
    end
  end
end
