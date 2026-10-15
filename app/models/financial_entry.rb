class FinancialEntry < ApplicationRecord
  belongs_to :order, optional: true

  enum :entry_type, { income: "income", expense: "expense" }
  enum :status, { pending: "pending", paid: "paid", cancelled: "cancelled" }

  validates :description, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
end
