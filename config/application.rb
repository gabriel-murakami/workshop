require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Workshop
  class Application < Rails::Application
    config.load_defaults 7.2

    config.time_zone = "America/Sao_Paulo"

    config.api_only = true

    config.autoload_paths << Rails.root.join("app/layers")
    config.eager_load_paths << Rails.root.join("app/layers")

    config.generators do |generator|
      generator.orm :active_record, primary_key_type: :uuid
    end
  end
end
