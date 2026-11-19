class CreateAttendanceRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :attendance_records, id: :uuid do |t|
      t.references :employee_detail,
                   type: :uuid,
                   null: false,
                   foreign_key: true

      t.datetime :checkin_time
      t.datetime :checkout_time

      t.timestamps

      t.index [ :employee_detail_id, :checkin_time ],
              unique: true,
              name: "index_unique_employee_attendance"
    end
  end
end
