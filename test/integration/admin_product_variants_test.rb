require "test_helper"

class AdminProductVariantsTest < ActionDispatch::IntegrationTest
  setup do
    @admin = Admin.create!(email: "admin-opcoes@exemplo.test", password: "senha-segura-123", password_confirmation: "senha-segura-123")
    @category = Category.create!(name: "Quitandas", slug: "quitandas", active: true)
    post admin_session_path, params: { admin: { email: @admin.email, password: "senha-segura-123" } }
  end

  test "admin cadastra opções com preço e estoque no próprio produto" do
    post admin_products_path, params: {
      product: {
        category_id: @category.id, name: "Mãe Benta", description: "Caseira", price: "R$ 15,00", active: "1", position: "0",
        product_variants_attributes: {
          "0" => { name: "Sem goiabada — 10 unidades", price: "R$ 15,00", quantity: "5", low_stock_threshold: "1", active: "1" },
          "1" => { name: "Com goiabada — 20 unidades", price: "R$ 38,00", quantity: "3", low_stock_threshold: "1", active: "1" }
        }
      }
    }

    product = Product.find_by!(name: "Mãe Benta")

    assert_redirected_to admin_products_path
    assert_equal({ "Sem goiabada — 10 unidades" => 15.to_d, "Com goiabada — 20 unidades" => 38.to_d }, product.product_variants.pluck(:name, :price).to_h)
    assert_equal [ 3, 5 ], product.product_variants.pluck(:quantity).sort

    get edit_admin_product_path(product)

    assert_response :success
    assert_select "legend", "Opções e preços"
    assert_select "[data-nested-form-target='list'] input[name*='[product_variants_attributes]'][name$='[name]']", count: 2
  end
end
