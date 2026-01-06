Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.base_controller_class = "ActionController::Base"
  config.lograge.formatter = Lograge::Formatters::Json.new
  config.lograge.ignore_actions = [ "Rails::HealthController#show" ]

  config.lograge.custom_options = lambda do |event|
    correlation = Datadog::Tracing.correlation
    {
      dd: {
        trace_id: correlation.trace_id.to_s,
        span_id:  correlation.span_id.to_s,
        env:      Rails.env,
        service:  "workshop"
      },
      ddsource: "ruby",
      params: event.payload[:params].except("controller", "action", "format", "id"),
      remote_ip: event.payload[:remote_ip],
      user_id: event.payload[:user_id],
      request_id: event.payload[:request_id]
    }
  end
end
