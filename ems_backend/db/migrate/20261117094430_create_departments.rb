class CreateDepartments < ActiveRecord::Migration[8.1]
  def change
    create_table :departments, id: :uuid do |t|
      t.string :department_name, null: false
      t.float :department_budget, null: false

      t.timestamps

      t.check_constraint "department_budget >= 0",
                          name: "department_budget_nonnegative"

      t.index :department_name, unique: true
    end
  end
end
