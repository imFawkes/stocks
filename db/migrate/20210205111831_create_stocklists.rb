class CreateStocklists < ActiveRecord::Migration[6.1]
  def change
    create_table :stocklists do |t|
      t.references :warehouse, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 0
      t.index [:warehouse_id, :product_id], unique: true
      t.timestamps
    end
  end
end
