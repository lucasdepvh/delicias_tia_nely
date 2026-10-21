require "test_helper"

class AdminCustomerShowTest < ActionDispatch::IntegrationTest
  setup do
    @admin = Admin.create!(email: "admin-clientes@exemplo.test", password: "senha-segura-123", password_confirmation: "senha-segura-123")
    @customer = Customer.create!(name: "Cliente de exemplo", phone: "11988887777", email: "cliente@exemplo.test", street: "Rua das Flores", number: "10", city: "Porto Velho", state: "RO")
    Order.create!(customer: @customer, number: "PED-CLIENTE-1", status: "pending", fulfillment_method: "pickup", payment_method: "pix", subtotal: 15, delivery_fee: 0, discount_amount: 0, total: 15)
  end

  test "admin visualiza cliente com retorno destacado e sem edição na página" do
    post admin_session_path, params: { admin: { email: @admin.email, password: "senha-segura-123" } }

    get admin_customer_path(@customer)

    assert_response :success
    assert_select "a.admin-form__cancel[href='#{admin_customers_path}']", text: "Voltar aos clientes"
    assert_select ".admin-customer-detail__card", count: 2
    assert_select "dd", text: "(11) 98888-7777"
    assert_select ".admin-customer-detail__order-count strong", "1"
    assert_select ".admin-customer-detail__order-count small", "pedido registrado"
    assert_select "a[href='#{edit_admin_customer_path(@customer)}']", count: 0
  end

  test "listagem usa ícones nas ações do cliente" do
    post admin_session_path, params: { admin: { email: @admin.email, password: "senha-segura-123" } }

    get admin_customers_path

    assert_response :success
    assert_select "a[aria-label='Ver cliente #{@customer.name}'] .material-symbols-rounded", text: "visibility"
    assert_select "a[aria-label='Editar cliente #{@customer.name}'] .material-symbols-rounded", text: "edit"
    assert_select "button[aria-label='Excluir cliente #{@customer.name}'] .material-symbols-rounded", text: "delete"
    assert_select ".admin-resource__list small", /1 pedido vinculado/
  end
end
