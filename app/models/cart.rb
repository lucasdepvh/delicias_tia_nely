class Cart
  Item = Struct.new(:key, :product, :variant, :quantity, keyword_init: true) do
    def unit_price
      variant ? variant.effective_price : product.price
    end

    def total
      unit_price * quantity
    end

    def name
      [ product.name, variant&.name ].compact.join(" — ")
    end
  end

  MAXIMUM_QUANTITY = 99

  def initialize(session)
    @session = session
    @entries = session[:cart_items] || {}
  end

  def items
    @entries.filter_map do |key, entry|
      product = Product.active.find_by(id: entry["product_id"] || entry[:product_id])
      next unless product

      variant_id = entry["variant_id"] || entry[:variant_id]
      variant = variant_id.present? ? product.product_variants.active.find_by(id: variant_id) : nil
      next if variant_id.present? && variant.nil?
      next if variant.nil? && product.product_variants.active.exists?
      next unless available?(product, variant)

      Item.new(key: key, product: product, variant: variant, quantity: entry["quantity"].to_i)
    end
  end

  def subtotal
    items.sum(&:total)
  end

  def quantity
    items.sum(&:quantity)
  end

  def empty?
    items.empty?
  end

  def add(product:, variant_id:, quantity:)
    variant = resolve_variant(product, variant_id)
    requested_quantity = integer_quantity(quantity)
    key = item_key(product, variant)
    requested_quantity += @entries.dig(key, "quantity").to_i
    validate_quantity!(requested_quantity, product, variant)
    @entries[key] = { "product_id" => product.id, "variant_id" => variant&.id, "quantity" => requested_quantity }
    persist
  end

  def update(key, quantity)
    begin
      requested_quantity = Integer(quantity.to_s, 10)
    rescue ArgumentError, TypeError
      raise ArgumentError, "Informe uma quantidade inteira válida."
    end
    return remove(key) if requested_quantity <= 0

    entry = @entries[key]
    raise ArgumentError, "Item não encontrado no carrinho." unless entry
    product = Product.active.find_by(id: entry["product_id"])
    unless product
      remove(key)
      return "Item indisponível removido do carrinho."
    end
    begin
      variant = resolve_variant(product, entry["variant_id"])
    rescue ArgumentError
      remove(key)
      return "Opção indisponível removida do carrinho."
    end
    unless available?(product, variant)
      remove(key)
      return "Item esgotado removido do carrinho."
    end
    limit = variant ? variant.quantity : (product.track_inventory? ? product.quantity : MAXIMUM_QUANTITY)
    entry["quantity"] = [requested_quantity, MAXIMUM_QUANTITY, limit].min
    persist
    entry["quantity"] < requested_quantity ? "Quantidade ajustada ao estoque disponível e ao limite de 99 unidades." : "Carrinho atualizado."
  end

  def validated_items!
    raise ArgumentError, "Seu carrinho está vazio." if @entries.empty?

    @entries.map do |key, entry|
      product = Product.active.find_by(id: entry["product_id"])
      raise ArgumentError, "Um produto do carrinho não está mais disponível. Revise o carrinho." unless product
      variant = resolve_variant(product, entry["variant_id"])
      quantity = integer_quantity(entry["quantity"])
      validate_quantity!(quantity, product, variant)
      Item.new(key: key, product: product, variant: variant, quantity: quantity)
    end
  end

  def remove(key)
    @entries.delete(key)
    persist
  end

  def clear
    @session.delete(:cart_items)
    @session.delete(:cart_coupon)
    @entries = {}
  end

  private

  def resolve_variant(product, variant_id)
    if product.product_variants.active.exists? && variant_id.blank?
      raise ArgumentError, "Escolha uma opção do produto antes de adicionar ao carrinho."
    end
    return nil if variant_id.blank?

    variant = product.product_variants.active.find_by(id: variant_id)
    raise ArgumentError, "A opção escolhida não está disponível para este produto." unless variant
    variant
  end

  def available?(product, variant)
    return variant.available? if variant
    product.available?
  end

  def integer_quantity(value)
    quantity = Integer(value.to_s, 10)
    raise ArgumentError, "Informe uma quantidade válida." unless quantity.positive?
    quantity
  rescue ArgumentError, TypeError
    raise ArgumentError, "Informe uma quantidade válida."
  end

  def validate_quantity!(quantity, product, variant)
    raise ArgumentError, "O limite é de #{MAXIMUM_QUANTITY} unidades por item." if quantity > MAXIMUM_QUANTITY
    raise ArgumentError, "Este produto não está disponível no momento." unless available?(product, variant)
    available_stock = variant ? variant.quantity : product.quantity
    tracks_stock = variant.present? || product.track_inventory?
    raise ArgumentError, "A quantidade solicitada não está disponível." if tracks_stock && quantity > available_stock
  end

  def item_key(product, variant)
    "#{product.id}:#{variant&.id || 'produto'}"
  end

  def persist
    @session[:cart_items] = @entries
  end
end
