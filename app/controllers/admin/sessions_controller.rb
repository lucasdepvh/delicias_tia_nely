class Admin::SessionsController < Devise::SessionsController
  layout "application"
  before_action :set_private_response_headers

  protected

  def after_sign_in_path_for(_resource)
    admin_root_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end

  private

  def set_private_response_headers
    response.headers["X-Robots-Tag"] = "noindex, nofollow"
    response.headers["Cache-Control"] = "no-store"
  end
end
