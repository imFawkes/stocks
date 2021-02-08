class Stocklist < ApplicationRecord
  belongs_to :warehouse
  belongs_to :product

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :product, uniqueness: { scope: :warehouse, case_sensitive: false }
end
