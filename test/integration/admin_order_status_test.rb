require "test_helper"

class AdminOrderStatusTest < ActionDispatch::IntegrationTest
  setup do
    @admin = Admin.create!(email: "admin-status@exemplo.test", password: "senha-segura-123", password_confirmation: "senha-segura-123")
    category = Category.create!(name: "Admin", slug: "admin")
    @product = Product.create!(category: category, name: "Produto", slug: "produto-admin", price: 10, active: true, track_inventory: true, quantity: 2)
    customer = Customer.create!(name: "Cliente", phone: "11988887777")
    @order = Order.create!(customer: customer, number: "PED-ADMIN", status: "pending", fulfillment_method: "pickup", payment_method: "pix", subtotal: 10, delivery_fee: 0, discount_amount: 0, total: 10)
    @order.order_items.create!(product: @product, product_name: "Produto", quantity: 1, unit_price: 10, total: 10)
    FinancialEntry.create!(order: @order, entry_type: "income", status: "pending", automatic: true, description: "Pedido #{@order.number}", amount: 10, due_date: Date.current)
  end

  test "visitante nao altera status e admin confirmado baixa estoque" do
    patch admin_order_path(@order), params: { order: { status: "confirmed" } }
    assert_redirected_to new_admin_session_path
    assert_equal "pending", @order.reload.status

    post admin_session_path, params: { admin: { email: @admin.email, password: "senha-segura-123" } }
    patch admin_order_path(@order), params: { order: { status: "confirmed" } }
    assert_redirected_to admin_order_path(@order)
    assert_equal "confirmed", @order.reload.status
    assert_equal 1, @product.reload.quantity

    get admin_order_path(@order)
    assert_response :success
    assert_select "form[action='#{admin_order_path(@order)}'][method='post']"
    assert_select "li", /Baixa pelo pedido/
  end
end
