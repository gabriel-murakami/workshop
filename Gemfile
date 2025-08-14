source "https://rubygems.org"

ruby "3.3.9"

gem "rails", "~> 8.0.2"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false
gem "jwt"
gem "bcrypt"
gem "cpf_cnpj"
gem "active_model_serializers"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
# gem "rack-cors"

group :test do
  gem "simplecov", require: false
  gem "simplecov-console", require: false
  gem "simplecov-json", require: false
  gem "rswag-specs"
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "brakeman", require: false
end

group :development, :test do
  gem "rswag-ui"
  gem "rswag-api"
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "rubocop-rails-omakase", require: false
end
