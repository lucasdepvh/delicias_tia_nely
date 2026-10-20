require "test_helper"

class AdminOrdersIndexTest < ActionDispatch::IntegrationTest
  setup do
    @admin = Admin.create!(email: "admin-pedidos@exemplo.test", password: "senha-segura-123", password_confirmation: "senha-segura-123")
    customer = Customer.create!(name: "Cliente de pedidos", phone: "11988887777")
    @order = Order.create!(customer: customer, number: "PED-LISTA", status: "pending", fulfillment_method: "pickup", payment_method: "pix", subtotal: 15, delivery_fee: 0, discount_amount: 0, total: 15)
  end

  test "admin visualiza pedidos com data localizada" do
    post admin_session_path, params: { admin: { email: @admin.email, password: "senha-segura-123" } }

    get admin_orders_path

    assert_response :success
    assert_select "td", text: I18n.l(@order.created_at, format: :short)
  end
end
