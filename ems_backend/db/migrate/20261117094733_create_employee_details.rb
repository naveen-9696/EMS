class CreateEmployeeDetails < ActiveRecord::Migration[8.1]
  def change
    create_table :employee_details, id: :uuid do |t|
      t.references :user,
                   type: :uuid,
                   null: false,
                   foreign_key: true,
                   index: { unique: true }

      t.references :department,
                   type: :uuid,
                   null: false,
                   foreign_key: true

      t.string :designation

      t.float :base_salary,
                default: 0.0,
                null: false
                
      t.date :start_date
      t.date :end_date
      t.timestamps

      t.check_constraint "base_salary >= 0",
                         name: "employee_details_salary_nonnegative"
    end
  end
end
