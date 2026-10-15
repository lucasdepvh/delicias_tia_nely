class CartController < PublicController
  before_action :require_accepting_orders!, only: :create

  def show
    @cart = current_cart
  end

  def create
    product = Product.active.find_by!(id: cart_params[:product_id])
    current_cart.add(product: product, variant_id: cart_params[:variant_id], quantity: cart_params[:quantity])
    redirect_back fallback_location: produto_path(product.slug), notice: "Produto adicionado ao carrinho."
  rescue ActiveRecord::RecordNotFound
    redirect_to produtos_path, alert: "Produto não encontrado ou indisponível."
  rescue ArgumentError => e
    redirect_back fallback_location: produtos_path, alert: e.message
  end

  def update
    current_cart.update(params[:key], cart_params[:quantity])
    redirect_to carrinho_path, notice: "Carrinho atualizado."
  rescue ArgumentError => e
    redirect_to carrinho_path, alert: e.message
  end

  def destroy
    current_cart.remove(params[:key])
    redirect_to carrinho_path, notice: "Item removido do carrinho."
  end

  def clear
    current_cart.clear
    redirect_to carrinho_path, notice: "Carrinho esvaziado."
  end

  private

  def cart_params
    params.require(:cart_item).permit(:product_id, :variant_id, :quantity)
  end
end
