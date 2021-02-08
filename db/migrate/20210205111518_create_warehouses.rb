class CreateWarehouses < ActiveRecord::Migration[6.1]
  def change
    create_table :warehouses do |t|
      t.string :name
      t.string :address
      t.integer :balance

      t.timestamps
    end
  end
end
