class CreateJobWorkChallans < ActiveRecord::Migration[8.0]
  def change
    create_table :job_work_challans do |t|
      t.references :job_worker, null: false, foreign_key: true
      t.datetime :issued_date, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :expected_return_date, null: false
      t.string :status, default: 'Pending'

      t.timestamps
    end
  end
end
