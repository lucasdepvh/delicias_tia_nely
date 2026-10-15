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
  def product_params = params.require(:product).permit(:category_id, :name, :slug, :description, :price, :active, :featured, :track_inventory, :quantity, :low_stock_threshold, :position, :main_image)
end
