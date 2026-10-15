Devise.setup do |config|
  require "devise/orm/active_record"

  config.mailer_sender = ENV.fetch("DEVISE_MAILER_SENDER", "nao-responda@localhost")
  config.parent_controller = "ApplicationController"
  config.case_insensitive_keys = [ :email ]
  config.strip_whitespace_keys = [ :email ]
  config.skip_session_storage = [ :http_auth ]
  config.stretches = Rails.env.test? ? 1 : 12
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete
  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other
end
