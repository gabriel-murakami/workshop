FactoryBot.define do
  factory :metric, class: "Domain::ServiceOrder::Metric" do
    service_order_count { rand(1..100) }
    average_time { rand(0.0..120.0).round(2) }
  end
end
