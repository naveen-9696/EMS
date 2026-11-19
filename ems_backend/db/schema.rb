# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_17_103302) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "attendance_exception_days", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "attendance_exception_id"
    t.date "leave_date", null: false
    t.string "status", default: "pending", null: false
    t.text "admin_reason"
    t.string "leave_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attendance_exception_id", "leave_date"], name: "index_unique_attendance_exception_days", unique: true
    t.index ["attendance_exception_id"], name: "index_attendance_exception_days_on_attendance_exception_id"
  end

  create_table "attendance_exceptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "employee_detail_id"
    t.date "start_date"
    t.date "end_date"
    t.string "reason"
    t.string "request_type"
    t.string "status"
    t.datetime "checkin_time"
    t.datetime "checkout_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_detail_id"], name: "index_attendance_exceptions_on_employee_detail_id"
  end

  create_table "attendance_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "employee_detail_id", null: false
    t.datetime "checkin_time"
    t.datetime "checkout_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_detail_id", "checkin_time"], name: "index_unique_employee_attendance", unique: true
    t.index ["employee_detail_id"], name: "index_attendance_records_on_employee_detail_id"
  end

  create_table "departments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "department_name", null: false
    t.float "department_budget", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_name"], name: "index_departments_on_department_name", unique: true
    t.check_constraint "department_budget >= 0::double precision", name: "department_budget_nonnegative"
  end

  create_table "employee_details", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "department_id", null: false
    t.string "designation"
    t.decimal "base_salary", default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_employee_details_on_department_id"
    t.index ["user_id"], name: "index_employee_details_on_user_id", unique: true
    t.check_constraint "base_salary >= 0::numeric", name: "employee_details_salary_nonnegative"
  end

  create_table "roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.uuid "department_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_roles_on_department_id"
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "salary_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "employee_detail_id", null: false
    t.integer "month", null: false
    t.integer "year", null: false
    t.float "payable_salary", default: 0.0
    t.float "base_salary", default: 0.0
    t.integer "present_days", default: 0
    t.integer "approved_leave_days", default: 0
    t.integer "paid_leave_days", default: 0
    t.float "salary_adjustments", default: 0.0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_detail_id", "month", "year"], name: "index_unique_employee_salary_records", unique: true
    t.index ["employee_detail_id"], name: "index_salary_records_on_employee_detail_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "status"
    t.string "phase"
    t.string "encrypted_password", default: "", null: false
    t.uuid "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  add_foreign_key "attendance_exception_days", "attendance_exceptions"
  add_foreign_key "attendance_exceptions", "employee_details"
  add_foreign_key "attendance_records", "employee_details"
  add_foreign_key "employee_details", "departments"
  add_foreign_key "employee_details", "users"
  add_foreign_key "roles", "departments"
  add_foreign_key "salary_records", "employee_details"
  add_foreign_key "users", "roles"
end
