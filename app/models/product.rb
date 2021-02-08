class Product < ApplicationRecord
  has_many :stocklists
  has_many :warehouses, through: :stocklists

  validates :name, presence: true
  validates :price, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
