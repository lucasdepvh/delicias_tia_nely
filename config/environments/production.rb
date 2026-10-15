require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
  config.assets.compile = false
  config.active_storage.service = :local
  config.force_ssl = ENV.fetch("FORCE_SSL", "true") == "true"
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.log_tags = [ :request_id ]
  config.cache_store = :memory_store
  config.active_job.queue_adapter = :inline
  config.action_mailer.perform_caching = false
  config.action_mailer.raise_delivery_errors = ENV["SMTP_ADDRESS"].present?
  config.action_mailer.default_url_options = { host: ENV.fetch("APP_HOST") }
  config.action_mailer.delivery_method = :smtp if ENV["SMTP_ADDRESS"].present?
  config.action_mailer.smtp_settings = {
    address: ENV["SMTP_ADDRESS"], port: ENV.fetch("SMTP_PORT", 587).to_i,
    user_name: ENV["SMTP_USERNAME"], password: ENV["SMTP_PASSWORD"],
    domain: ENV["SMTP_DOMAIN"], authentication: :plain, enable_starttls_auto: true
  } if ENV["SMTP_ADDRESS"].present?
  config.i18n.fallbacks = true
  config.active_support.report_deprecations = false
end
