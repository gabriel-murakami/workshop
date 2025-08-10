FactoryBot.define do
  factory :auto_part, class: "Domain::ServiceOrderItem::AutoPart" do
    name { "Oil Filter" }
    description { "Engine oil filter" }
    stock_quantity { 10 }
    base_price { 49.90 }
    sequence(:sku) { |n| "AP#{format('%03d', n)}" }
  end
end
