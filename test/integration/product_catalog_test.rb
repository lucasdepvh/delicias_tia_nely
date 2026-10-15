require "test_helper"

class ProductCatalogTest < ActionDispatch::IntegrationTest
  setup do
    @category = Category.create!(name: "Cremosos", slug: "cremosos", active: true)
    @available_product = Product.create!(category: @category, name: "Quitanda cremosa", slug: "quitanda-cremosa", price: 5.5, active: true)
    @sold_out_product = Product.create!(category: @category, name: "Quitanda esgotada", slug: "quitanda-esgotada", price: 6, active: true, track_inventory: true, quantity: 0)
    @inactive_product = Product.create!(category: @category, name: "Quitanda inativa", slug: "quitanda-inativa", price: 7, active: false)
  end

  test "catálogo público mostra somente produtos ativos e informa disponibilidade" do
    get produtos_path

    assert_response :success
    assert_select "h1", /Sabores para adoçar/
    assert_select ".product-card", 2
    assert_select ".product-card", /Quitanda cremosa/
    assert_select ".product-card", /Quitanda esgotada/
    assert_select ".product-card", text: /Quitanda inativa/, count: 0
    assert_select ".product-card__availability", /Indisponível/
  end

  test "categoria e detalhe do produto ativo são públicos" do
    get sabores_path
    assert_response :success

    get categoria_path(@category.slug)
    assert_response :success
    assert_select "h1", @category.name

    get produto_path(@available_product.slug)
    assert_response :success
    assert_select "h1", @available_product.name
    assert_select ".product-detail__availability", /Disponível no cardápio/
  end

  test "produto inativo não é exposto diretamente" do
    get produto_path(@inactive_product.slug)
    assert_response :not_found
  end
end
