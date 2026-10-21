require "test_helper"

class AdminFinancialEntryShowTest < ActionDispatch::IntegrationTest
  setup do
    @admin = Admin.create!(email: "financeiro@exemplo.test", password: "senha-segura-123", password_confirmation: "senha-segura-123")
    customer = Customer.create!(name: "Cliente financeiro", phone: "11977776666")
    order = Order.create!(customer: customer, number: "PED-FINANCEIRO", status: "pending", fulfillment_method: "pickup", payment_method: "pix", subtotal: 25, delivery_fee: 0, discount_amount: 0, total: 25)
    @entry = FinancialEntry.create!(order: order, description: "Receita do pedido PED-FINANCEIRO", entry_type: "income", status: "pending", automatic: true, amount: 25, due_date: Date.current)
  end

  test "lançamento automático abre diretamente o pedido vinculado" do
    post admin_session_path, params: { admin: { email: @admin.email, password: "senha-segura-123" } }

    get admin_financial_entry_path(@entry)

    assert_redirected_to admin_order_path(@entry.order)
  end
end
