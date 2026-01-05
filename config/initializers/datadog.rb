Datadog.configure do |c|
  c.service = "workshop"
  c.env = Rails.env
  c.version = "1.0.0"

  c.tracing.enabled = true
  c.tracing.log_injection = true

  c.tracing.instrument :rails
  c.tracing.instrument :active_record
  c.tracing.instrument :redis
  c.tracing.instrument :http
end
