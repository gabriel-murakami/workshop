FactoryBot.define do
  factory :service_order_item, class: "Domain::ServiceOrderItem::ServiceOrderItem" do
    association :service_order
    quantity { 1 }
    item_type { "Service" }
    item_id { create(:service).id }
  end
end
