source "https://rubygems.org"

ruby "3.3.9"

gem "rails", "~> 7.2.2", ">= 7.2.2.1"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false
gem "jwt"
gem "bcrypt"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
# gem "rack-cors"

group :development, :test do
  gem "simplecov", require: false
  gem "simplecov-console"
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "rswag-api"
  gem "rswag-ui"
  gem "rswag-specs"
  gem "rspec-rails"
  gem "faker"
  gem "factory_bot_rails"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end
