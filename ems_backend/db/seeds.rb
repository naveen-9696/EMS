
# ==========================================
# 1. DEPARTMENTS
# ==========================================

it = Department.find_or_create_by!(
  department_name: "IT"
) do |department|
  department.department_budget = 500000.0
end

sales = Department.find_or_create_by!(
  department_name: "Sales"
) do |department|
  department.department_budget = 300000.0
end

marketing = Department.find_or_create_by!(
  department_name: "Marketing"
) do |department|
  department.department_budget = 250000.0
end

hr = Department.find_or_create_by!(
  department_name: "HR"
) do |department|
  department.department_budget = 200000.0
end

# ==========================================
# 2. ROLES
# ==========================================

admin = Role.find_or_create_by!(name: "Admin") do |role|
  role.department = nil
end

# hr_role = Role.find_or_create_by!(name: "HR") do |role|
#   role.department = nil
# end

employee = Role.find_or_create_by!(name: "Employee") do |role|
  role.department = nil
end

# ==========================================
# 3. USERS
# ==========================================

admin = User.find_or_create_by!(
  email: "admin@ems.com"
) do |user|
  user.name = "Admin User"
  user.password = "Password@123"
  user.status = "active"
  user.phase = "permanent"
  user.role = admin
end

user1 = User.find_or_create_by!(
  email: "user1@ems.com"
) do |user|
  user.name = "user 1"
  user.password = "Password@123"
  user.status = "active"
  user.phase = "permanent"
  user.role = employee
end

user2 = User.find_or_create_by!(
  email: "user2@ems.com"
) do |user|
  user.name = " User 2"
  user.password = "Password@123"
  user.status = "active"
  user.phase = "permanent"
  user.role = employee
end

user3 = User.find_or_create_by!(
  email: "user3@ems.com"
) do |user|
  user.name = "User 3"
  user.password = "Password@123"
  user.status = "active"
  user.phase = "permanent"
  user.role = employee
end

user4 = User.find_or_create_by!(
  email: "user4@ems.com"
) do |user|
  user.name = "Admin User"
  user.password = "Admin@123"
  user.status = "active"
  user.phase = "permanent"
  user.role = employee
end

user5 = User.find_or_create_by!(
  email: "user5@ems.com"
) do |user|
  user.name = "Admin User"
  user.password = "Password@123"
  user.status = "active"
  user.phase = "permanent"
  user.role = employee
end

user6 = User.find_or_create_by!(
  email: "user6@ems.com"
) do |user|
  user.name = "Admin User"
  user.password = "Password@123"
  user.status = "active"
  user.phase = "permanent"
  user.role = employee
end

# ==========================================
# 4. EMPLOYEE DETAILS
# ==========================================
[
  "Junior Software Engineer",
  "Software Engineer",
  "Senior Software Engineer"
]

employee1 = EmployeeDetail.find_or_create_by!(
  user: user1,
  department: it,
  designation: "Junior Software Engineer",
  base_salary: 45000
)

employee2 = EmployeeDetail.find_or_create_by!(
  user: user2,
  department: it,
  designation: "Software Engineer",
  base_salary: 55000
)

employee3 = EmployeeDetail.find_or_create_by!(
  user: user3,
  department: it,
  designation: "Senior Software Engineer",
  base_salary: 85000
)

employee4 = EmployeeDetail.find_or_create_by!(
  user: user4,
  department: sales,
  designation: "Senior Software Engineer",
  base_salary: 40000
)

employee5 = EmployeeDetail.find_or_create_by!(
  user: user5,
  department: marketing,
  designation: "Senior Software Engineer",
  base_salary: 35000
)

employee6 = EmployeeDetail.find_or_create_by!(
  user: user6,
  department: hr,
  designation: "Senior Software Engineer",
  base_salary: 38000
)

# ==========================================
# 5. ATTENDANCE RECORDS
# ==========================================

attendance1 = AttendanceRecord.find_or_create_by!(
  employee_detail: employee1,
  checkin_time: Time.zone.parse("2026-11-02 09:00:00"),
  checkout_time: Time.zone.parse("2026-11-02 18:00:00")
)

attendance2 = AttendanceRecord.find_or_create_by!(
  employee_detail: employee1,
  checkin_time: Time.zone.parse("2026-11-03 09:15:00"),
  checkout_time: Time.zone.parse("2026-11-03 18:10:00")
)

attendance3 = AttendanceRecord.find_or_create_by!(
  employee_detail: employee2,
  checkin_time: Time.zone.parse("2026-11-02 09:30:00"),
  checkout_time: Time.zone.parse("2026-11-02 18:00:00")
)

attendance4 = AttendanceRecord.find_or_create_by!(
  employee_detail: employee3,
  checkin_time: Time.zone.parse("2026-11-02 08:45:00"),
  checkout_time: Time.zone.parse("2026-11-02 17:45:00")
)

attendance5 = AttendanceRecord.find_or_create_by!(
  employee_detail: employee4,
  checkin_time: Time.zone.parse("2026-11-02 10:00:00"),
  checkout_time: Time.zone.parse("2026-11-02 19:00:00")
)

# ==========================================
# 6. ATTENDANCE EXCEPTIONS
# ==========================================

leave_request = AttendanceException.find_or_create_by!(
  employee_detail: employee1,
  start_date: Date.new(2026, 11, 9),
  end_date: Date.new(2026, 11, 11),
  reason: "Personal work",
  request_type: "leave",
  status: "approved"
)

regularization_request = AttendanceException.find_or_create_by!(
  employee_detail: employee2,
  start_date: Date.new(2026, 11, 3),
  end_date: Date.new(2026, 11, 3),
  reason: "Forgot to check out",
  request_type: "regularization",
  status: "pending",
  checkin_time: Time.zone.parse("2026-11-03 09:30:00"),
  checkout_time: Time.zone.parse("2026-11-03 18:00:00")
)

# ==========================================
# 7. ATTENDANCE EXCEPTION DAYS
# ==========================================

[
  [ Date.new(2026, 11, 9), "approved" ],
  [ Date.new(2026, 11, 10), "approved" ],
  [ Date.new(2026, 11, 11), "approved" ]
].each do |date, status|
  AttendanceExceptionDay.find_or_create_by!(
    attendance_exception: leave_request,
    leave_date: date,
    status: status,
    leave_type: "paid",
    admin_reason: "Approved by admin"
  )
end

# ==========================================
# 8. SALARY RECORDS
# ==========================================

# SalaryRecord.create!(
#   employee_detail: employee1,
#   month: 10,
#   year: 2026,
#   base_salary: 45000,
#   present_days: 20,
#   approved_leave_days: 2,
#   paid_leave_days: 2,
#   payable_salary: 45000
# )

# SalaryRecord.create!(
#   employee_detail: employee2,
#   month: 10,
#   year: 2026,
#   base_salary: 55000,
#   present_days: 19,
#   approved_leave_days: 1,
#   paid_leave_days: 1,
#   payable_salary: 50000
# )

# SalaryRecord.create!(
#   employee_detail: employee3,
#   month: 10,
#   year: 2026,
#   base_salary: 85000,
#   present_days: 22,
#   approved_leave_days: 0,
#   paid_leave_days: 0,
#   payable_salary: 85000
# )

# SalaryRecord.create!(
#   employee_detail: employee4,
#   month: 10,
#   year: 2026,
#   base_salary: 40000,
#   present_days: 18,
#   approved_leave_days: 2,
#   paid_leave_days: 2,
#   payable_salary: 36363.64
# )

puts "EMS seed data created successfully!"
