class CreateJobWorkItems < ActiveRecord::Migration[8.0]
  def change
    create_table :job_work_items do |t|
      t.references :job_work_challan, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.integer :quantity_issued, null: false
      t.integer :quantity_received, default: 0
      t.integer :quantity_scrapped, default: 0

      t.timestamps
    end
  end
end
