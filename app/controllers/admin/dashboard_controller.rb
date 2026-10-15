class Admin::DashboardController < Admin::BaseController
  def index
    @store_setting = StoreSetting.current
    @recent_orders = Order.table_exists? ? Order.includes(:customer).order(created_at: :desc).limit(6) : []
    @pending_orders = Order.table_exists? ? Order.pending.count : 0
    @today_orders = Order.table_exists? ? Order.where(created_at: Time.zone.today.all_day).where.not(status: :cancelled) : []
    @today_total = @today_orders.respond_to?(:sum) ? @today_orders.sum(:total) : 0
    @low_stock_products = Product.where(track_inventory: true).where("quantity <= low_stock_threshold").order(:quantity, :name).limit(6)
  end

  def toggle_orders
    setting = StoreSetting.find_or_create_by!(singleton_key: StoreSetting::SINGLETON_KEY)
    setting.update!(accepting_orders: !setting.accepting_orders?)
    redirect_to admin_root_path, notice: setting.accepting_orders? ? "Loja habilitada para receber pedidos." : "Loja pausada para novos pedidos."
  end
end
