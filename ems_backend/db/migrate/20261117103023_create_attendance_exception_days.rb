class CreateAttendanceExceptionDays < ActiveRecord::Migration[8.1]
  def change
    create_table :attendance_exception_days, id: :uuid do |t|
      t.references :attendance_exception,
                   type: :uuid,
                   foreign_key: true

      t.date :leave_date, null: false
      t.string :status, default: "pending", null: false
      t.text :admin_reason
      t.string :leave_type

      t.timestamps

      t.index [ :attendance_exception_id, :leave_date ],
              unique: true,
              name: "index_unique_attendance_exception_days"
    end
  end
end
