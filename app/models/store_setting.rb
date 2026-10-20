class StoreSetting < ApplicationRecord
  SINGLETON_KEY = "current".freeze
  DEFAULT_PAUSE_MESSAGE = "No momento não estamos recebendo pedidos. Voltamos em breve.".freeze

  validates :singleton_key, inclusion: { in: [ SINGLETON_KEY ] }, uniqueness: true
  validates :store_name, presence: true
  validates :minimum_order_value, :default_delivery_fee, numericality: { greater_than_or_equal_to: 0 }

  def self.current
    find_by(singleton_key: SINGLETON_KEY) || new(
      singleton_key: SINGLETON_KEY,
      store_name: "Delícias da Tia Nely",
      accepting_orders: false,
      minimum_order_value: 0,
      default_delivery_fee: 10,
      pause_message: DEFAULT_PAUSE_MESSAGE
    )
  end

  def effective_minimum_order_value
    [ minimum_order_value || 0, BigDecimal("20") ].max
  end

  def commercial_details_ready?
    store_name.present? && whatsapp_number.to_s.gsub(/\D/, "").match?(/\A[1-9]\d{9,14}\z/)
  end

  def accepting_orders?
    accepting_orders && commercial_details_ready?
  end

  def toggle_order_acceptance!
    if accepting_orders?
      update!(accepting_orders: false)
      :paused
    elsif commercial_details_ready?
      update!(accepting_orders: true)
      :activated
    else
      update!(accepting_orders: false)
      :missing_commercial_details
    end
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[store_name accepting_orders minimum_order_value default_delivery_fee]
  end
end
