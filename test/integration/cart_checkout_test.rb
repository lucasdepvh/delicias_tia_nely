require "test_helper"

class CartCheckoutTest < ActionDispatch::IntegrationTest
  setup do
    StoreSetting.create!(singleton_key: StoreSetting::SINGLETON_KEY, store_name: "Delícias da Tia Nely", whatsapp_number: "5511999999999", accepting_orders: true, minimum_order_value: 0, default_delivery_fee: 10)
    category = Category.create!(name: "Quitandas", slug: "quitandas")
    @product = Product.create!(category: category, name: "Bolo caseiro", slug: "bolo-caseiro", price: 25, active: true)
  end

  test "adiciona item e cria pedido de retirada encaminhando ao WhatsApp" do
    post cart_items_path, params: { cart_item: { product_id: @product.id, quantity: 1 } }
    assert_redirected_to produto_path(@product.slug)

    get finalizar_pedido_path
    assert_response :success
    assert_select ".order-checkout"
    assert_select "h1", "Detalhes do pedido"
    assert_select "form[data-turbo='false'] input[name='customer[name]']"
    assert_select "form[data-turbo='false'] input[name='order[fulfillment_method]'][value='delivery']"
    assert_select ".order-checkout__summary"
    assert_select ".order-checkout svg.checkout-icon", minimum: 10
    assert_select ".order-checkout", text: /local_shipping/, count: 0

    assert_difference [ "Order.count", "OrderItem.count", "FinancialEntry.count" ], 1 do
      post finalizar_pedido_path, params: { customer: { name: "Ana", phone: "(11) 99999-9999" }, order: { fulfillment_method: "pickup", payment_method: "pix", notes: "Sem açúcar" } }
    end
    assert_response :see_other
    assert_match %r{\Ahttps://wa\.me/5511999999999\?text=}, response.location
    order = Order.last
    assert_equal "pending", order.status
    assert_equal BigDecimal("25"), order.total
    assert_equal "11999999999", order.customer.phone
  end

  test "loja pausada bloqueia adicionar e abrir checkout" do
    StoreSetting.current.update!(accepting_orders: false)
    post cart_items_path, params: { cart_item: { product_id: @product.id, quantity: 1 } }
    assert_redirected_to produtos_path
    get finalizar_pedido_path
    assert_redirected_to produtos_path
  end
end
