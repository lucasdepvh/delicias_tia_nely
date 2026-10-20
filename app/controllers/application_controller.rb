class ApplicationController < ActionController::Base
  include Pagy::Method

  before_action :authenticate_admin!

  helper_method :current_cart

  private

  # O layout público também é usado pelas telas Devise de sessão e senha.
  # Mantêm o carrinho na sessão e o disponibiliza a qualquer controller que
  # renderize esse layout.
  def current_cart
    @current_cart ||= Cart.new(session)
  end

  def after_sign_in_path_for(_resource)
    admin_root_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end
end
