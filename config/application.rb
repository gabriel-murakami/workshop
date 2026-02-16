require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Workshop
  class Application < Rails::Application
    config.load_defaults 7.2

    config.time_zone = "America/Sao_Paulo"

    # Forma correta no Rails 7.2
    # config.paths.add "app/layers", eager_load: true

    config.api_only = true

    config.generators do |generator|
      generator.orm :active_record, primary_key_type: :uuid
    end
  end
end
