require "test_helper"

class CatalogSeedTest < ActiveSupport::TestCase
  EXPECTED_QUITANDAS = {
    "Rosquinhas de Leite Condensado com Coco" => {
      "15 unidades" => "45.0",
      "30 unidades" => "85.0"
    },
    "Mãe Benta" => {
      "Sem goiabada — 10 unidades" => "15.0",
      "Sem goiabada — 20 unidades" => "28.0",
      "Com goiabada — 10 unidades" => "20.0",
      "Com goiabada — 20 unidades" => "38.0"
    },
    "Pão Santo Antônio Tradicional" => {
      "10 unidades" => "20.0",
      "20 unidades" => "38.0"
    },
    "Pão de Coco" => {
      "5 unidades" => "15.0",
      "10 unidades" => "25.0"
    },
    "Bolinho do Céu com Coco" => {
      "500 ml (~45 un.)" => "16.0",
      "1 litro (~90 un.)" => "30.0"
    }
  }.freeze

  test "seed cadastra o catálogo de quitandas sem duplicar produtos ou variações" do
    load Rails.root.join("db/seeds.rb")
    category = Category.find_by!(slug: "quitandas-da-tia-nely")
    first_product_ids = category.products.order(:id).pluck(:id)
    first_variant_ids = ProductVariant.where(product_id: first_product_ids).order(:id).pluck(:id)

    load Rails.root.join("db/seeds.rb")

    assert_equal first_product_ids, category.products.order(:id).pluck(:id)
    assert_equal first_variant_ids, ProductVariant.where(product_id: first_product_ids).order(:id).pluck(:id)
    assert_equal EXPECTED_QUITANDAS.keys.sort, category.products.pluck(:name).sort

    EXPECTED_QUITANDAS.each do |product_name, expected_variants|
      product = category.products.find_by!(name: product_name)

      assert_equal expected_variants, product.product_variants.pluck(:name, :price).to_h.transform_values(&:to_s)
      assert_not product.main_image.attached?
      assert_not product.track_inventory?
    end
  end
end
