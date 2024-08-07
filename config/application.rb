require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"


# If you get NameError: uninitialized constant,
# you have to use require like this one:
require_relative '../app/middleware/handle_bad_encoding_middleware.rb'


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

# Load application ENV vars and merge with existing ENV vars. Loaded here so can use values in initializers.
# ENV.update YAML.load_file('config/application.yml')[Rails.env] rescue {}


# config = YAML.load_file('config/application.yml')
# config.merge! config.fetch(Rails.env, {})
# config.each do |key, value|
#   # ENV[key] ||= value.to_s unless value.kind_of? Hash
#   ENV[key] ||= value.to_s
# end


module CollectionGuides
  class Application < Rails::Application
    
    # Fix for resque-web
    Resque::Version = Resque::VERSION
    
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.active_record.yaml_column_permitted_classes = [Symbol, Hash, Array, ActiveSupport::HashWithIndifferentAccess]
    
    # Load application ENV vars and merge with existing ENV vars. Loaded here so can use values in initializers.
    ENV.update YAML.load(ERB.new(File.read("config/application.yml")).result, aliases: true)[Rails.env] rescue {}

    # config.middleware.insert_before Rack::Runtime, HandleBadEncodingMiddleware

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    # config.autoload_paths += Dir["#{config.root}/app/**/"]

    if Rails.env == 'test'
      config.autoload_paths += %W(#{config.root}/spec)
      config.autoload_paths += Dir["#{config.root}/spec/**/"]
    end

    config.active_job.queue_adapter = :resque

    config.action_mailer.delivery_method = :sendmail
    config.action_mailer.perform_deliveries = true
    config.action_mailer.raise_delivery_errors = true
    config.active_job.queue_adapter = :resque

  end
end
