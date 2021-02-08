require 'rails_helper'

RSpec.describe Warehouse, type: :model do
  context 'associations' do
    it { is_expected.to have_many(:products) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:address) }
    it { is_expected.to validate_presence_of(:balance) }
    it { is_expected.to validate_numericality_of(:balance).only_integer.is_greater_than_or_equal_to(0) }
  end
end
