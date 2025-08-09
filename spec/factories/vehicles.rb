FactoryBot.define do
  factory :vehicle, class: "Domain::Customer::Vehicle" do
    association :customer

    license_plate { "#{Faker::Alphanumeric.alpha(number: 3).upcase}-#{Faker::Number.number(digits: 4)}" }
    brand { Faker::Vehicle.make }
    model { Faker::Vehicle.model }
    year { Faker::Vehicle.year }
  end
end
