class CreateAttendanceExceptions < ActiveRecord::Migration[8.1]
  def change
    create_table :attendance_exceptions, id: :uuid do |t|
      t.references :employee_detail,
                   type: :uuid,
                   foreign_key: true

      t.date :start_date
      t.date :end_date
      t.string :reason
      t.string :request_type
      t.string :status
      t.datetime :checkin_time
      t.datetime :checkout_time

      t.timestamps
    end
  end
end
