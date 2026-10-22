setting = StoreSetting.find_or_create_by!(singleton_key: StoreSetting::SINGLETON_KEY) do |record|
  record.store_name = "Delícias da Tia Nely"
  record.whatsapp_number = ENV["STORE_WHATSAPP"].presence
  record.accepting_orders = false
  record.minimum_order_value = 0
  record.default_delivery_fee = BigDecimal("10")
  record.pause_message = StoreSetting::DEFAULT_PAUSE_MESSAGE
end

admin_email = ENV["SEED_ADMIN_EMAIL"].presence
admin_password = ENV["SEED_ADMIN_PASSWORD"].presence

if admin_email.present? || admin_password.present?
  raise "Defina SEED_ADMIN_EMAIL e SEED_ADMIN_PASSWORD juntos." unless admin_email.present? && admin_password.present?

  Admin.find_or_create_by!(email: admin_email.strip.downcase) do |admin|
    admin.password = admin_password
    admin.password_confirmation = admin_password
  end
end

# As imagens deste catálogo são anexadas manualmente pelo formulário administrativo.
initial_catalog = [
    {
      name: "Rosquinhas de Leite Condensado com Coco",
      description: "Caseiras com leite condensado e coco.",
      variants: [[ "15 unidades", "45.00" ], [ "30 unidades", "85.00" ]]
    },
    {
      name: "Mãe Benta",
      description: nil,
      variants: [
        [ "Sem goiabada — 10 unidades", "15.00" ],
        [ "Sem goiabada — 20 unidades", "28.00" ],
        [ "Com goiabada — 10 unidades", "20.00" ],
        [ "Com goiabada — 20 unidades", "38.00" ]
      ]
    },
    {
      name: "Pão Santo Antônio Tradicional",
      description: "Pãozinho macio e caseiro.",
      variants: [[ "10 unidades", "20.00" ], [ "20 unidades", "38.00" ]]
    },
    {
      name: "Pão de Coco",
      description: "Pãozinho caseiro com coco.",
      variants: [[ "5 unidades", "15.00" ], [ "10 unidades", "25.00" ]]
    },
    {
      name: "Bolinho do Céu com Coco",
      description: "Bolinhas douradas com coco ralado.",
      variants: [[ "500 ml (~45 un.)", "16.00" ], [ "1 litro (~90 un.)", "30.00" ]]
    }
]

category = Category.find_or_create_by!(slug: "quitandas-da-tia-nely") do |record|
    record.name = "Quitandas da Tia Nely"
    record.description = "Receitas caseiras feitas com amor, como antigamente."
    record.active = true
    record.position = 0
end

initial_catalog.each_with_index do |catalog_product, position|
    product = Product.find_or_create_by!(slug: catalog_product[:name].parameterize) do |record|
      record.category = category
      record.name = catalog_product[:name]
      record.description = catalog_product[:description]
      record.price = BigDecimal(catalog_product[:variants].first.last)
      record.active = true
      record.featured = false
      record.track_inventory = false
      record.position = position
    end

    catalog_product[:variants].each do |name, price|
      ProductVariant.find_or_create_by!(product: product, name: name) do |record|
        record.price = BigDecimal(price)
        record.active = true
        record.quantity = 0
        record.low_stock_threshold = 0
      end
    end
end

frozen_or_baked_catalog = [
    {
      name: "Pão de Queijo",
      variants: [
        [ "Congelado — 10 unidades", "25.00" ],
        [ "Congelado — 25 unidades", "60.00" ],
        [ "Assado — 10 unidades", "35.00" ],
        [ "Assado — 25 unidades", "70.00" ]
      ]
    },
    {
      name: "Biscoito de Queijo",
      variants: [
        [ "Congelado — 10 unidades", "35.00" ],
        [ "Congelado — 25 unidades", "75.00" ],
        [ "Assado — 10 unidades", "40.00" ],
        [ "Assado — 25 unidades", "81.00" ]
      ]
    }
]

frozen_or_baked_category = Category.find_or_create_by!(slug: "congelados-ou-assados") do |record|
    record.name = "Congelados ou Assados"
    record.description = "Escolha congelado para assar em casa ou peça assado, pronto para servir."
    record.active = true
    record.position = 1
end

frozen_or_baked_catalog.each_with_index do |catalog_product, position|
    product = Product.find_or_create_by!(slug: catalog_product[:name].parameterize) do |record|
      record.category = frozen_or_baked_category
      record.name = catalog_product[:name]
      record.price = BigDecimal(catalog_product[:variants].first.last)
      record.active = true
      record.featured = false
      record.track_inventory = false
      record.position = position
    end

    catalog_product[:variants].each do |name, price|
      ProductVariant.find_or_create_by!(product: product, name: name) do |record|
        record.price = BigDecimal(price)
        record.active = true
        record.quantity = 0
        record.low_stock_threshold = 0
      end
    end
end

sandwiches_category = Category.find_or_create_by!(slug: "sanduiches-de-pao-santo-antonio") do |record|
    record.name = "Sanduíches de Pão Santo Antônio"
    record.description = "Pequenos sanduíches preparados com nosso tradicional Pão Santo Antônio."
    record.active = true
    record.position = 2
end

sandwiches = Product.find_or_create_by!(slug: "sanduiches-de-pao-santo-antonio") do |record|
    record.category = sandwiches_category
    record.name = "Sanduíches de Pão Santo Antônio"
    record.description = "R$ 7,00 por unidade. Pedido mínimo: 30 unidades (a partir de R$ 210,00). Ideal para reuniões, cafés, aniversários e confraternizações."
    record.price = BigDecimal("7.00")
    record.active = true
    record.featured = false
    record.track_inventory = false
    record.position = 0
end

[
    [ "Geleia de Pimenta", "Muçarela, alface americana, tomate, geleia de pimenta e pimenta biquinho." ],
    [ "Patê de Atum", "Muçarela e patê cremoso de atum com requeijão, finalizado com azeitona." ],
    [ "Presunto e Queijo", "Presunto, muçarela, alface americana, tomate e tomate-cereja." ]
].each do |name, description|
    ProductVariant.find_or_create_by!(product: sandwiches, name: name) do |record|
      record.price = BigDecimal("7.00")
      record.active = true
      record.quantity = 0
      record.low_stock_threshold = 0
    end
end
