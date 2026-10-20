class Customer < ApplicationRecord
  has_many :orders, dependent: :restrict_with_error

  before_validation :normalize_phone

  validates :name, :phone, presence: true
  validates :phone, uniqueness: true
  validates :phone, format: { with: /\A\d{10,15}\z/, message: "deve conter DDD e número válidos" }

  def self.ransackable_attributes(_auth_object = nil)
    %w[name phone email city state created_at]
  end

  private

  def normalize_phone
    self.phone = phone.to_s.gsub(/\D/, "")
  end
end
