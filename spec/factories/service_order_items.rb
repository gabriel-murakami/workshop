FactoryBot.define do
  factory :service_order_item, class: "Domain::ServiceOrder::ServiceOrderItem" do
    association :service_order
    quantity { 1 }
    item_kind { "service" }
    item_id { create(:service).id }
  end
end
