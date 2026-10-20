class Admin::OrdersController < Admin::BaseController
  before_action :set_order, only: %i[show update]

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
    @order = Order.includes(:customer, :order_items, :stock_movements).find(params[:id])
  end

  def update
    @order.transition_to!(order_params[:status])
    redirect_to admin_order_path(@order), notice: "Status do pedido atualizado."
  rescue ArgumentError, ActiveRecord::RecordInvalid => e
    redirect_to admin_order_path(@order), alert: e.message
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:status)
  end
end
