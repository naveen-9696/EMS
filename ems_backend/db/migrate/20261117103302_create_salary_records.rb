class CreateSalaryRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :salary_records, id: :uuid do |t|
      t.references :employee_detail,
                   type: :uuid,
                   null: false,
                   foreign_key: true

      t.integer :month, null: false
      t.integer :year, null: false

      t.float :payable_salary, default: 0.0

      t.float :base_salary, default: 0.0

      t.integer :present_days, default: 0
      t.integer :approved_leave_days, default: 0
      t.integer :paid_leave_days, default: 0
      t.float :salary_adjustments, null: false, default: 0
      t.timestamps

      t.index [ :employee_detail_id, :month, :year ],
              unique: true,
              name: "index_unique_employee_salary_records"
    end
  end
end
