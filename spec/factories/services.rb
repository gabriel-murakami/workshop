FactoryBot.define do
  factory :service, class: "Domain::Catalog::Service" do
    name { "Oil Change" }
    description { "Replacement of engine oil" }
    base_price { 120.0 }
    sequence(:code) { |n| "SVC#{format('%03d', n)}" }
  end
end
