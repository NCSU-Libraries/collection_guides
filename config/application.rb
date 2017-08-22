require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

# Load application ENV vars and merge with existing ENV vars. Loaded here so can use values in initializers.
ENV.update YAML.load_file('config/application.yml')[Rails.env] rescue {}

# config = YAML.load_file('config/application.yml')
# config.merge! config.fetch(Rails.env, {})
# config.each do |key, value|
#   # ENV[key] ||= value.to_s unless value.kind_of? Hash
#   ENV[key] ||= value.to_s
# end


module AspacePublic
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    if Rails.env == 'test'
      config.autoload_paths += %W(#{config.root}/spec)
      config.autoload_paths += Dir["#{config.root}/spec/**/"]
    end
  end
end
