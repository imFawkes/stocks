require 'rails_helper'

RSpec.describe Stocklist, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:product) }
    it { is_expected.to belong_to(:warehouse) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:quantity) }
    it { is_expected.to validate_numericality_of(:quantity).only_integer.is_greater_than_or_equal_to(0) }
    context 'should not create second stocklist with same product and warehouse' do
      let(:product) { create(:product) }
      let(:warehouse) { create(:warehouse) }
      let!(:stocklist) { create(:stocklist, product: product, warehouse: warehouse) }
      let(:stocklist2) { build(:stocklist, product: product, warehouse: warehouse) }
      it do
        expect(stocklist).not_to eq(nil)
        expect { stocklist2.save! }.to raise_exception(ActiveRecord::RecordInvalid)
      end
    end
  end
end
