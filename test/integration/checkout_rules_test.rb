require "test_helper"
require "uri"

class CheckoutRulesTest < ActionDispatch::IntegrationTest
  setup do
    @setting = StoreSetting.create!(singleton_key: "current", store_name: "Loja de teste",
      whatsapp_number: "5511999999999", accepting_orders: true, minimum_order_value: 0, default_delivery_fee: 10)
    category = Category.create!(name: "Teste", slug: "teste")
    @product = Product.create!(category: category, name: "Produto teste", slug: "produto-teste", price: 25, active: true)
    @customer_data = { name: "Cliente de teste", phone: "(11) 99999-1234" }
    @order_data = { fulfillment_method: "pickup", payment_method: "pix" }
  end

  def add(quantity = 1, **attributes)
    post cart_items_path, params: { cart_item: { product_id: @product.id, quantity: quantity }.merge(attributes) }
  end

  def checkout(customer: {}, order: {})
    post finalizar_pedido_path, params: { customer: @customer_data.merge(customer), order: @order_data.merge(order) }
  end

  test "persiste pedido pendente e financeiro e redireciona com mensagem codificada" do
    add
    assert_difference ["Order.count", "OrderItem.count", "FinancialEntry.count"], 1 do
      checkout(order: { payment_method: "cash", change_for: "50", notes: "Sem açúcar & com carinho" })
    end
    assert_response :see_other
    uri = URI(response.location)
    assert_equal "wa.me", uri.host
    assert_equal "/5511999999999", uri.path
    message = URI.decode_www_form(uri.query).to_h.fetch("text")
    assert_includes message, "Pagamento: Dinheiro"
    assert_includes message, "Troco para: R$ 50,00"
    assert_includes message, "Sem açúcar & com carinho"
    assert_equal "pending", Order.last.status
    assert_not Order.last.stock_deducted
    assert_equal Order.last.total, FinancialEntry.last.amount
    get carrinho_path
    assert_select ".commerce-empty"
    assert_select "a[href='#{pedido_path(Order.last.number)}']"
  end

  test "aceita troco com a máscara monetária brasileira" do
    add

    checkout(order: { payment_method: "cash", change_for: "R$ 50,00" })

    assert_response :see_other
    assert_equal BigDecimal("50"), Order.last.change_for
  end

  test "resumo so pode ser lido pela sessao que criou o pedido" do
    add
    checkout
    order = Order.last
    get pedido_path(order.number)
    assert_response :success
    assert_equal "no-store", response.headers["Cache-Control"]
    assert_select "a[href^='https://wa.me/']"
    other = open_session
    other.get pedido_path(order.number)
    assert_equal 404, other.response.status
  end

  test "queda de estoque apos adicionar impede pedido e mantem carrinho" do
    @product.update!(track_inventory: true, quantity: 2)
    add(2)
    @product.update!(quantity: 1)
    assert_no_difference ["Order.count", "Customer.count", "FinancialEntry.count"] do
      checkout
    end
    assert_response :unprocessable_entity
    get carrinho_path
    assert_select ".cart-item"
  end

  test "produto inativo nao permite finalizar" do
    add
    @product.update!(active: false)
    assert_no_difference("Order.count") { checkout }
    assert_response :unprocessable_entity
  end

  test "modalidade e pagamento invalidos retornam 422" do
    add
    assert_no_difference("Order.count") { checkout(order: { fulfillment_method: "falso", payment_method: "falso" }) }
    assert_response :unprocessable_entity
    assert_select "input[name='customer[name]'][value='Cliente de teste']"
  end

  test "minimo vale antes do frete e tambem na retirada" do
    @product.update!(price: 15)
    add
    assert_no_difference("Order.count") { checkout }
    assert_response :unprocessable_entity
    assert_no_difference("Order.count") { checkout(order: { fulfillment_method: "delivery" }, customer: address) }
    assert_response :unprocessable_entity
    @product.update!(price: 25)
    @setting.update!(minimum_order_value: 30)
    assert_no_difference("Order.count") { checkout }
    assert_response :unprocessable_entity
  end

  test "pausa depois de abrir formulario bloqueia post" do
    add
    get finalizar_pedido_path
    assert_response :success
    assert_select "form[data-turbo='false']"
    @setting.update!(accepting_orders: false)
    assert_no_difference("Order.count") { checkout }
    assert_redirected_to produtos_path
  end

  test "configuracao de whatsapp invalida bloqueia vendas" do
    @setting.update!(whatsapp_number: "abc")
    add
    assert_redirected_to produtos_path
  end

  test "entrega usa area normalizada e ignora total vindo do cliente" do
    area = DeliveryArea.create!(name: "São José", slug: "sao-jose", fee: "7.50")
    add
    checkout(customer: address.merge(neighborhood: "SAO JOSE"), order: { fulfillment_method: "delivery", total: "0.01", delivery_fee: 0, status: "delivered" })
    assert_response :see_other
    assert_equal area.id, Order.last.delivery_area_id
    assert_equal BigDecimal("32.50"), Order.last.total
    assert_equal "pending", Order.last.status
  end

  test "sem area aplica taxa padrao e retirada tem frete zero" do
    add
    checkout(customer: address, order: { fulfillment_method: "delivery" })
    assert_response :see_other
    assert_equal BigDecimal("10"), Order.last.delivery_fee
    assert_nil Order.last.delivery_area_id
    add
    checkout
    assert_response :see_other
    assert_equal 0, Order.last.delivery_fee
    assert_equal 1, Customer.count
  end

  test "endereco telefone e troco invalidos nao persistem" do
    add
    assert_no_difference(["Order.count", "Customer.count"]) { checkout(customer: { phone: "1" }, order: { fulfillment_method: "delivery" }) }
    assert_response :unprocessable_entity
    assert_no_difference("Order.count") { checkout(order: { payment_method: "cash", change_for: "2" }) }
    assert_response :unprocessable_entity
    assert_no_difference("Order.count") { checkout(order: { change_for: "50" }) }
    assert_response :unprocessable_entity
  end

  test "falha financeira reverte pedido cliente e itens" do
    add
    # A restrição temporária simula uma falha de validação ao criar a receita.
    validator = ->(entry) { entry.errors.add(:base, "Falha de teste") }
    FinancialEntry.validate(validator)
    begin
      assert_no_difference ["Order.count", "Customer.count", "OrderItem.count", "FinancialEntry.count"] do
        checkout
      end
      assert_response :unprocessable_entity
      get carrinho_path
      assert_select ".cart-item"
    ensure
      FinancialEntry.skip_callback(:validate, :before, validator)
    end
  end

  test "turbo atualiza contador e drawer sem exibir aviso de sucesso" do
    post cart_items_path, params: { cart_item: { product_id: @product.id, quantity: 1 } },
      headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_select "turbo-stream[target='cart-count'] template", text: "1"
    assert_select "turbo-stream[target='cart-drawer-content']"
    assert_select "turbo-stream[target='cart-feedback'] template", text: "Produto adicionado ao carrinho."
    assert_select "turbo-stream[target='drawer']", count: 0
    assert_select "turbo-stream[target='cart-drawer-content'] a[href='#{finalizar_pedido_path}']", "Finalizar pedido"
    assert_select "turbo-stream[target='cart-drawer-content'] .cart-drawer__item-image, turbo-stream[target='cart-drawer-content'] .cart-drawer__item-placeholder", 1
    assert_select "turbo-stream[target='cart-drawer-content'] .cart-drawer__footer"
    assert_select "turbo-stream[target='cart-drawer-content'] .cart-drawer__update input[data-action='change->cart-drawer#updateQuantity']"
    assert_select "turbo-stream[target='cart-drawer-content'] .cart-drawer__remove svg.navigation-icon"
  end

  test "quantidades invalidas nao removem item e atualizacao limita estoque" do
    @product.update!(track_inventory: true, quantity: 3)
    add(2)
    patch cart_item_path("#{@product.id}:produto"), params: { cart_item: { quantity: "abc" } }
    get carrinho_path
    assert_select ".cart-item input[value='2']"
    patch cart_item_path("#{@product.id}:produto"), params: { cart_item: { quantity: 999 } }
    get carrinho_path
    assert_select ".cart-item input[value='3']"
    patch cart_item_path("#{@product.id}:produto"), params: { cart_item: { quantity: 0 } }
    get carrinho_path
    assert_select ".commerce-empty"
  end

  test "adicoes repetidas nao ultrapassam 99 e variacao invalida nao vira produto" do
    add(99)
    add
    get carrinho_path
    assert_select ".cart-item input[value='99']"
    delete carrinho_path
    add(1, variant_id: 99999)
    get carrinho_path
    assert_select ".commerce-empty"
  end

  test "variacao usa preco proprio e estoque proprio" do
    variant = @product.product_variants.create!(name: "Opção", price: 30, quantity: 2, active: true)
    add(1, variant_id: variant.id)
    checkout
    assert_response :see_other
    assert_equal BigDecimal("30"), Order.last.total
    assert_equal variant.id, OrderItem.last.product_variant_id
    assert_equal 2, variant.reload.quantity
  end

  test "opcao esgotada nao permite comprar produto sem variante" do
    @product.product_variants.create!(name: "Caixa", price: 30, quantity: 0, active: true)

    get produto_path(@product.slug)
    assert_select "form[action='#{cart_items_path}']", count: 0

    add
    assert_response :see_other
    get carrinho_path
    assert_select ".commerce-empty"
    assert_no_difference("Order.count") { checkout }
    assert_response :unprocessable_entity
  end

  test "cep invalido retorna erro sem consulta externa" do
    get cep_path("123")
    assert_response :unprocessable_entity
    assert_includes response.parsed_body["error"], "8 dígitos"
  end

  private

  def address
    { zip_code: "01001-000", street: "Rua de teste", number: "10", neighborhood: "Centro", city: "Cidade de teste", state: "SP" }
  end
end
