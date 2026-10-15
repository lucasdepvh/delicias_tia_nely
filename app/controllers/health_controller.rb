class HealthController < PublicController
  def show
    ActiveRecord::Base.connection_pool.with_connection { |connection| connection.active? }
    render json: { status: "ok" }, status: :ok
  rescue StandardError
    render json: { status: "indisponivel" }, status: :service_unavailable
  end
end
