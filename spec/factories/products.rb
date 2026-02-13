FactoryBot.define do
  factory :product, class: "Domain::Catalog::Product" do
    name { "Oil Filter" }
    description { "Engine oil filter" }
    stock_quantity { 10 }
    base_price { 49.90 }
    sequence(:sku) { |n| "AP#{format('%03d', n)}" }
  end
end
