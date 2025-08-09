FactoryBot.define do
  factory :service, class: "Domain::ServiceOrderItem::Service" do
    name { "Oil Change" }
    description { "Replacement of engine oil" }
    base_price { 120.0 }
  end
end
