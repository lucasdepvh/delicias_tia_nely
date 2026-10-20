class PublicController < ApplicationController
  skip_before_action :authenticate_admin!

  layout "application"

  private

  def require_accepting_orders!
    setting = StoreSetting.current
    return if setting.accepting_orders?

    redirect_to produtos_path, alert: setting.pause_message.presence || StoreSetting::DEFAULT_PAUSE_MESSAGE
  end
end
