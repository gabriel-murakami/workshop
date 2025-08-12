ENV['RAILS_ENV'] ||= 'test'
ENV['SIMPLECOV'] ||= 'true'

require 'simplecov'
require 'simplecov-console'
require 'simplecov-json'

if ENV['SIMPLECOV'] == 'true'
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::JSONFormatter,
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::Console
  ])

  SimpleCov.start 'rails' do
    add_filter '/spec/'
    add_filter '/config/'
    add_filter 'app/layers/web/channels/application_cable'
  end
end

require File.expand_path('../config/environment', __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.use_transactional_fixtures = true
  config.filter_rails_from_backtrace!
end
