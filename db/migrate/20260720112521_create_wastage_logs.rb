class CreateWastageLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :wastage_logs do |t|
      t.references :item, null: false, foreign_key: true
      t.integer :quantity_wasted, null: false
      t.string :reason_code, null: false
      t.decimal :estimated_cost, precision: 10, scale: 2, null: false
      t.datetime :logged_at, default: -> { 'CURRENT_TIMESTAMP' }

      t.timestamps
    end
  end
end
