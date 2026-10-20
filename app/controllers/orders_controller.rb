class OrdersController < PublicController
  def show
    raise ActiveRecord::RecordNotFound unless Array(session[:order_numbers]).include?(params[:number])

    @order = Order.includes(:customer, :order_items).find_by!(number: params[:number])
    response.headers["X-Robots-Tag"] = "noindex, nofollow"
    response.headers["Cache-Control"] = "no-store"
  end
end
