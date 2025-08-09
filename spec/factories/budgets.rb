FactoryBot.define do
  factory :budget, class: "Domain::ServiceOrder::Budget" do
    association :service_order
    date { Date.current }
    total_value { 500.0 }
    status { "pending" }
  end
end
