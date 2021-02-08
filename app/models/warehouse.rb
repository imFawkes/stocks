class Warehouse < ApplicationRecord
  has_many :stocklists
  has_many :products, through: :stocklists

  validates :name, presence: true
  validates :address, presence: true
  validates :balance, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
