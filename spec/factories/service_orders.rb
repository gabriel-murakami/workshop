FactoryBot.define do
  factory :service_order, class: "Domain::ServiceOrder::ServiceOrder" do
    association :customer
    association :vehicle
    service_started_at { Time.current }
    service_finished_at { nil }
    status { "received" }
    description { "Oil change and full inspection" }
  end
end
