class HomeController < PublicController
  def index
    @store_setting = StoreSetting.current
    @categories = Category.where(active: true).display_order
    @products = Product.active.includes(:category).display_order.limit(24)
  end
end
