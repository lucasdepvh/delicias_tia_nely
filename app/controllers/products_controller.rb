class ProductsController < PublicController
  def index
    @categories = Category.where(active: true).display_order
    @category = @categories.find_by!(slug: params[:slug] || params[:category]) if params[:slug].present? || params[:category].present?

    @store_setting = StoreSetting.current
    products = Product.active.includes(:category, :product_variants).display_order
    products = products.where(category: @category) if @category
    @products = products.limit(12)
  end

  def show
    @product = Product.active.includes(:category, :product_variants).find_by!(slug: params[:slug])
    @store_setting = StoreSetting.current
    @variants = @product.product_variants.active.to_a
    @available_variants = @variants.select(&:available?)
    @related_products = Product.active.includes(:category).where(category: @product.category).where.not(id: @product.id).display_order.limit(4)
  end
end
