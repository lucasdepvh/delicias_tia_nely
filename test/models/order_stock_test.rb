require "test_helper"

class OrderStockTest < ActiveSupport::TestCase
  setup do
    category = Category.create!(name: "Estoque", slug: "estoque")
    @product = Product.create!(category: category, name: "Quitanda", slug: "quitanda", price: 10, active: true, track_inventory: true, quantity: 10)
    @customer = Customer.create!(name: "Cliente", phone: "11999999999")
  end

  test "primeiro status consumidor baixa produto uma vez e registra movimento" do
    order = create_order(quantity: 3)

    order.transition_to!("confirmed")

    assert_equal "confirmed", order.status
    assert order.stock_deducted?
    assert_equal 7, @product.reload.quantity
    movement = order.stock_movements.sole
    assert_equal(-3, movement.quantity)
    assert_equal "sale", movement.movement_type

    order.transition_to!("preparing")
    assert_equal 7, @product.reload.quantity
    assert_equal 1, order.stock_movements.count
  end

  test "falta de estoque nao muda pedido, saldo ou financeiro" do
    order = create_order(quantity: 11)

    error = assert_raises(ArgumentError) { order.transition_to!("confirmed") }

    assert_includes error.message, "Estoque insuficiente"
    assert_equal "pending", order.reload.status
    assert_not order.stock_deducted?
    assert_equal 10, @product.reload.quantity
    assert_equal 0, order.stock_movements.count
    assert_equal "pending", order.automatic_financial_entry.reload.status
  end

  test "demanda de itens repetidos e produto inativo impedem baixa parcial" do
    order = create_order(quantity: 2)
    order.order_items.create!(product: @product, product_name: "Quitanda", quantity: 3, unit_price: 10, total: 30)
    @product.update!(quantity: 4)

    assert_raises(ArgumentError) { order.transition_to!("confirmed") }
    assert_equal 4, @product.reload.quantity
    assert_equal 0, order.stock_movements.count

    @product.update!(quantity: 10, active: false)
    assert_raises(ArgumentError) { order.transition_to!("confirmed") }
    assert_equal "pending", order.reload.status
    assert_equal 10, @product.reload.quantity
  end

  test "variacao baixa apenas o proprio saldo" do
    variant = @product.product_variants.create!(name: "Pequena", active: true, quantity: 4)
    order = create_order(quantity: 2, product_variant: variant)

    order.transition_to!("ready")

    assert_equal 2, variant.reload.quantity
    assert_equal 10, @product.reload.quantity
    movement = order.stock_movements.sole
    assert_equal variant, movement.product_variant
    assert_nil movement.product
  end

  test "cancelamento restaura uma vez e uma reativacao faz nova baixa" do
    order = create_order(quantity: 4)
    order.transition_to!("confirmed")

    order.transition_to!("cancelled")
    assert_equal 10, @product.reload.quantity
    assert_not order.stock_deducted?
    assert_equal "cancelled", order.automatic_financial_entry.reload.status
    assert_nil order.automatic_financial_entry.paid_at
    assert_equal [-4, 4], order.stock_movements.order(:created_at).pluck(:quantity)

    order.transition_to!("cancelled")
    assert_equal 10, @product.reload.quantity
    assert_equal 2, order.stock_movements.count

    order.transition_to!("confirmed")
    assert_equal 6, @product.reload.quantity
    assert order.stock_deducted?
    assert_equal [-4, 4, -4], order.stock_movements.order(:created_at).pluck(:quantity)
  end

  test "voltar para pendente nao restaura estoque e entregue marca receita paga" do
    order = create_order(quantity: 2)
    order.transition_to!("confirmed")

    order.transition_to!("pending")
    assert_equal 8, @product.reload.quantity
    assert order.stock_deducted?
    assert_equal "pending", order.automatic_financial_entry.reload.status

    order.transition_to!("delivered")
    entry = order.automatic_financial_entry.reload
    assert_equal "paid", entry.status
    assert_equal Date.current, entry.paid_at
    assert_equal 8, @product.reload.quantity
  end

  private

  def create_order(quantity:, product_variant: nil)
    order = Order.create!(customer: @customer, number: "PED-#{SecureRandom.hex(6)}", status: "pending", fulfillment_method: "pickup", payment_method: "pix", subtotal: quantity * 10, delivery_fee: 0, discount_amount: 0, total: quantity * 10)
    order.order_items.create!(product: @product, product_variant: product_variant, product_name: "Quitanda", quantity: quantity, unit_price: 10, total: quantity * 10)
    FinancialEntry.create!(order: order, entry_type: "income", status: "pending", automatic: true, description: "Pedido #{order.number}", amount: order.total, due_date: Date.current)
    order
  end
end
