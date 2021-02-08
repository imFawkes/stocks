FactoryBot.define do
  factory :product do
    name { Faker::Device.model_name }
    price { Faker::Number.within(range: 10_000..50_000) }
  end
end
