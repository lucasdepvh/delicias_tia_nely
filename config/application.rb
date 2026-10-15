require_relative "boot"
require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module DeliciasDaTiaNely
  class Application < Rails::Application
    config.load_defaults 8.1
    config.time_zone = ENV.fetch("APP_TIME_ZONE", "America/Porto_Velho")
    config.i18n.default_locale = :"pt-BR"
    config.i18n.available_locales = [ :"pt-BR" ]
    config.generators.system_tests = nil
    config.active_storage.draw_routes = true
  end
end
