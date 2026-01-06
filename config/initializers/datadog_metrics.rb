require "datadog/statsd"

DATADOG_STATS = Datadog::Statsd.new(
  "datadog-agent.workshop.svc.cluster.local",
  ENV.fetch("DD_DOGSTATSD_PORT", 8125).to_i,
  namespace: "workshop"
)
