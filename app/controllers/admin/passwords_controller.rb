class Admin::PasswordsController < Devise::PasswordsController
  layout "application"
  before_action :set_private_response_headers

  private

  def set_private_response_headers
    response.headers["X-Robots-Tag"] = "noindex, nofollow"
    response.headers["Cache-Control"] = "no-store"
  end
end
