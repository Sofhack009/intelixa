class CreateItems < ActiveRecord::Migration[8.0]
  def change
    create_table :items do |t|
      t.string :sku_code, null: false
      t.string :name, null: false
      t.string :category
      t.string :item_type, null: false
      t.string :hsn_code
      t.integer :min_stock_level, default: 10

      t.timestamps
    end
    add_index :items, :sku_code, unique: true
  end
end
