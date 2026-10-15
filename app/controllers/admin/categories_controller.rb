class Admin::CategoriesController < Admin::BaseController
  before_action :set_category, only: %i[edit update destroy]

  def index
    @categories = Category.display_order
  end

  def new
    @category = Category.new(active: true)
  end

  def create
    @category = Category.new(category_params)
    return redirect_to admin_categories_path, notice: "Categoria criada." if @category.save

    render :new, status: :unprocessable_entity
  end

  def edit; end

  def update
    return redirect_to admin_categories_path, notice: "Categoria atualizada." if @category.update(category_params)

    render :edit, status: :unprocessable_entity
  end

  def destroy
    @category.destroy
    redirect_to admin_categories_path, notice: @category.errors.any? ? @category.errors.full_messages.to_sentence : "Categoria removida."
  end

  private

  def set_category = @category = Category.find(params[:id])
  def category_params = params.require(:category).permit(:name, :slug, :description, :active, :position)
end
