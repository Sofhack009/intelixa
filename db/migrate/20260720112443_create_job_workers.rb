class CreateJobWorkers < ActiveRecord::Migration[8.0]
  def change
    create_table :job_workers do |t|
      t.string :name, null: false
      t.string :process_type, null: false
      t.decimal :rate_per_unit, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
