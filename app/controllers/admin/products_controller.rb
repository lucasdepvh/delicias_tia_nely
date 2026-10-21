class Admin::ProductsController < Admin::BaseController
  before_action :set_product, only: %i[edit update destroy]

  def index
    @products = Product.includes(:category).display_order
  end

  def new
    @product = Product.new(active: true)
  end

  def create
    @product = Product.new(product_params)
    return redirect_to admin_products_path, notice: "Produto criado." if @product.save

    render :new, status: :unprocessable_entity
  end

  def edit; end

  def update
    return redirect_to admin_products_path, notice: "Produto atualizado." if @product.update(product_params)

    render :edit, status: :unprocessable_entity
  end

  def destroy
    @product.destroy
    redirect_to admin_products_path, notice: @product.errors.any? ? @product.errors.full_messages.to_sentence : "Produto removido."
  end

  private

  def set_product = @product = Product.find(params[:id])
  def product_params
    params.require(:product).permit(:category_id, :name, :slug, :description, :price, :active, :featured, :track_inventory, :quantity, :low_stock_threshold, :position, :main_image,
      product_variants_attributes: %i[id name price active quantity low_stock_threshold _destroy]).tap do |permitted|
      permitted[:price] = normalize_brl_amount(permitted[:price])
      permitted[:product_variants_attributes]&.each_value do |variant|
        variant[:price] = normalize_brl_amount(variant[:price])
      end
    end
  end

  def normalize_brl_amount(value)
    text = value.to_s.gsub(/[^\d,.-]/, "")
    text.include?(",") ? text.delete(".").tr(",", ".") : text
  end
end
