require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = true
  config.eager_load = false
  config.cache_classes = false
  config.consider_all_requests_local = true
  config.server_timing = true

  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.cache_store = :memory_store
    config.public_file_server.headers = { "Cache-Control" => "public, max-age=#{2.days.to_i}" }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  config.active_storage.service = :local
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
  config.active_support.deprecation = :log
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true
  config.active_job.verbose_enqueue_logs = true
  config.action_view.annotate_rendered_view_with_filenames = true
  config.action_controller.raise_on_missing_callback_actions = true

  config.logger = ActiveSupport::Logger.new(STDOUT)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  config.log_tags = []

  config.logger.formatter = proc do |severity, datetime, progname, msg|
    correlation = Datadog::Tracing.correlation

    # Estrutura base (Metadados do Sistema)
    json_log = {
      timestamp: datetime.iso8601,
      level: severity,
      progname: progname,
      dd: {
        trace_id: correlation.trace_id.to_s,
        span_id:  correlation.span_id.to_s,
        env:      Rails.env,
        service:  "workshop"
      },
      ddsource: "ruby"
    }

    if msg.is_a?(Hash)
      json_log[:data] = msg
    end

    json_log[:message] = msg.is_a?(String) ? msg.strip : msg.inspect

    json_log.to_json + "\n"
  end

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.smtp_settings = {
    address: "smtp.gmail.com",
    port: 587,
    domain: "gmail.com",
    user_name: ENV["SMTP_USERNAME"],
    password: ENV["SMTP_PASSWORD"],
    authentication: "plain",
    enable_starttls_auto: true
  }
end
