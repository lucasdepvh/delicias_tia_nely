class Admin::OrdersController < Admin::BaseController
  def index
    @status = params[:status].presence
    @query = params[:q].to_s.strip
    @orders = Order.includes(:customer).order(created_at: :desc)
    @orders = @orders.where(status: @status) if @status && Order.statuses.key?(@status)
    if @query.present?
      @orders = @orders.joins(:customer).where("orders.number LIKE :query OR customers.name LIKE :query OR customers.phone LIKE :query", query: "%#{@query}%")
    end
  end

  def show
    @order = Order.includes(:customer, :order_items).find(params[:id])
  end
end
