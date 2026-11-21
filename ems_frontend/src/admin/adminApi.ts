const apiBase = import.meta.env.VITE_API_URL

export type AttendanceExceptionItem = {
  attendance_exception: {
    id: string
    start_date: string
    end_date: string
    reason: string
    request_type: 'leave' | 'regularization'
    status: string
    checkin_time?: string | null
    checkout_time?: string | null
  }
  leave_dates?: string[]
  user?: { name?: string; email?: string }
}

export type AdminUser = {
  id: string
  name: string
  email: string
  phase: string | null
  status: string | null
  role_name?: string | null
}

export type AdminEmployee = {
  employee_detail: { id: string; user_id: string; department_id: string; designation: string; base_salary: number }
  user?: { id: string; name: string; email: string; status?: string; phase?: string; role_name?: string }
}

export type DepartmentOption = { id: string; department_name: string }

export type SalaryRecord = {
  id: string
  employee_detail_id: string
  month: number
  year: number
  base_salary: number
  payable_salary: number
  present_days: number
  approved_leave_days: number
  paid_leave_days: number
  salary_adjustments: number
}

export type AttendanceItem = {
  attendance_record: { id: string; employee_detail_id: string; checkin_time: string; checkout_time: string | null }
  user?: { id: string; name: string }
}

async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
  const token = sessionStorage.getItem('authToken')
  const response = await fetch(`${apiBase}${path}`, {
    ...options,
    headers: {
      Accept: 'application/json',
      ...(options.body ? { 'Content-Type': 'application/json' } : {}),
      ...(token ? { Authorization: token } : {}),
      ...options.headers,
    },
  })
  const data = await response.json().catch(() => ({}))

  if (!response.ok) {
    const problem = data.error?.msg ?? data.error ?? data.msg ?? data.errors ?? data.message
    const details = Array.isArray(problem) ? problem.join(' ') : typeof problem === 'string' ? problem : ''
    throw new Error(details || 'The request could not be completed.')
  }

  return data as T
}

export async function getAttendanceExceptions() {
  return request<{ data: AttendanceExceptionItem[] }>('/employee/attendance_exceptions')
}

export async function getUsers() {
  return request<{ data: AdminUser[] }>('/employee/users')
}

export async function getEmployees() {
  return request<AdminEmployee[]>('/admin/employees')
}

export async function getDepartments() {
  return request<{ data: DepartmentOption[] }>('/admin/departments')
}

export async function createEmployee(employee: { user_id: string; department_id: string; designation: string; base_salary: number }) {
  return request('/admin/employees', { method: 'POST', body: JSON.stringify({ employee }) })
}

export async function updateEmployee(employee: AdminEmployee['employee_detail']) {
  return request(`/admin/employees/${employee.id}`, {
    method: 'PATCH',
    body: JSON.stringify({ employee: { department_id: employee.department_id, designation: employee.designation, base_salary: employee.base_salary } }),
  })
}

export async function deleteEmployee(id: string) {
  return request(`/admin/employees/${id}`, { method: 'DELETE' })
}

export async function getSalaryRecords() {
  return request<{ data: SalaryRecord[] }>('/admin/salary_records')
}

export async function generateSalary(employeeId: string, month: number, year: number) {
  return request('/admin/salary_records', {
    method: 'POST',
    body: JSON.stringify({ employee_id: employeeId, month, year }),
  })
}

export async function getAttendanceRecords() {
  return request<AttendanceItem[]>('/employee/attendance_records')
}

export async function updateAttendance(item: AttendanceItem['attendance_record']) {
  return request(`/employee/employees/${item.employee_detail_id}/attendance_records/${item.id}`, {
    method: 'PUT',
    body: JSON.stringify({ attendance_record: { checkin_time: item.checkin_time, checkout_time: item.checkout_time } }),
  })
}

export async function updateLeaveStatus(id: string, status: 'approved' | 'rejected', dates: string[]) {
  return request(`/employee/attendance_exceptions/${id}/update_leave_days`, {
    method: 'PUT',
    body: JSON.stringify({ days: dates.map((leave_date) => ({ leave_date, status })) }),
  })
}

export async function updateRegularizationStatus(id: string, status: 'approved' | 'rejected') {
  return request(`/employee/attendance_exceptions/${id}/update_regularization`, {
    method: 'PUT',
    body: JSON.stringify({ attendance_exception: { status } }),
  })
}

export async function updateUser(user: AdminUser) {
  return request(`/employee/users/${user.id}`, {
    method: 'PUT',
    body: JSON.stringify({ user: { name: user.name, email: user.email, phase: user.phase, status: user.status } }),
  })
}

