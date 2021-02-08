require 'rails_helper'

RSpec.describe Product, type: :model do
  context 'associations' do
    it { is_expected.to have_many(:warehouses) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:price) }
    it { is_expected.to validate_numericality_of(:price).only_integer.is_greater_than(0) }
  end
end
