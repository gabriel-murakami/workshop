FactoryBot.define do
  factory :user, class: "Domain::ServiceOrder::User" do
    name { "Admin User" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
  end
end
