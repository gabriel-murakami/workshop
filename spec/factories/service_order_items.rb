FactoryBot.define do
  factory :service_order_item, class: "Domain::ServiceOrder::ServiceOrderItem" do
    association :service_order
    quantity { 1 }
    item_kind { "service" }
    item_id { Faker::Internet.uuid }
    item_code { "SVC007" }
    item_name { "Fake Service" }
  end
end
