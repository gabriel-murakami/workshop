source "https://rubygems.org"

gem "rails", "~> 7.2.2", ">= 7.2.2.1"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false
gem "jwt"
gem "bcrypt"
gem "cpf_cnpj"
gem "active_model_serializers"
gem "datadog", require: "datadog/auto_instrument"
gem "lograge"
gem "dogstatsd-ruby"

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
