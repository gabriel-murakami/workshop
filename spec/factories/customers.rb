FactoryBot.define do
  factory :customer, class: "Domain::Customer::Customer" do
    name { Faker::Name.name }
    document_number { Faker::IdNumber.brazilian_cpf }
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.cell_phone_in_e164 }
  end
end
