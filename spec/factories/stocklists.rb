FactoryBot.define do
  factory :stocklist do
    quantity { Faker::Number.within(range: 10..50) }

    association :product
    association :warehouse
  end
end
