FactoryBot.define do
  factory :service_order, class: "Domain::ServiceOrder::ServiceOrder" do
    association :customer
    association :vehicle
    opening_date { Time.current }
    closing_date { nil }
    status { "open" }
    description { "Oil change and full inspection" }
  end
end
