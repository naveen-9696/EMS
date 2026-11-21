import { useCallback, useEffect, useState } from 'react'
import { Alert, Box, Card, CardContent, Stack, Typography } from '@mui/material'
import GroupsRoundedIcon from '@mui/icons-material/GroupsRounded'
import BadgeRoundedIcon from '@mui/icons-material/BadgeRounded'
import EventBusyRoundedIcon from '@mui/icons-material/EventBusyRounded'
import AccessTimeRoundedIcon from '@mui/icons-material/AccessTimeRounded'
import DashboardHeader from '../dashboard/DashboardHeader'
import { getAttendanceExceptions, getAttendanceRecords, getDepartments, getEmployees, getUsers, type AttendanceExceptionItem, type AttendanceItem, type AdminEmployee, type AdminUser, type DepartmentOption } from './adminApi'

type OverviewData = {
  users: AdminUser[]
  employees: AdminEmployee[]
  requests: AttendanceExceptionItem[]
  attendance: AttendanceItem[]
  departments: DepartmentOption[]
}

const emptyData: OverviewData = { users: [], employees: [], requests: [], attendance: [], departments: [] }
const pieColors = ['#548e60', '#263d2d', '#91c69a', '#bfd9c3', '#8caa92', '#5d7163', '#d4e5d6', '#a1b7a5']

function EmployeePieChart({ title, description, items }: { title: string; description: string; items: { label: string; value: number }[] }) {
  const total = items.reduce((sum, item) => sum + item.value, 0)
  let currentStop = 0
  const slices = items.filter(({ value }) => value > 0).map((item) => {
    const start = currentStop
    currentStop += item.value / (total || 1) * 100
    return `${pieColors[items.indexOf(item) % pieColors.length]} ${start}% ${currentStop}%`
  })
  const chartBackground = total ? `conic-gradient(${slices.join(', ')})` : '#e8eee9'

  return <Card variant="outlined" className="overview-panel overview-pie-panel">
    <CardContent>
      <Typography className="overview-kicker">EMPLOYEE BREAKDOWN</Typography>
      <Typography variant="h6" component="h2">{title}</Typography>
      <Typography className="overview-pie-description">{description}</Typography>
      <Box className="overview-pie-layout">
        <Box className="overview-pie-chart" role="img" aria-label={`${title}: ${items.map(({ label, value }) => `${label}, ${value}`).join('; ')}`} sx={{ background: chartBackground }}>
          <span>{total}</span><small>Employees</small>
        </Box>
        <Box className="overview-pie-legend">
          {items.map(({ label, value }, index) => <Box className="overview-pie-legend-item" key={label}>
            <span className="overview-pie-dot" style={{ backgroundColor: pieColors[index % pieColors.length] }} />
            <span className="overview-pie-label">{label}</span><strong>{value}</strong>
          </Box>)}
          {items.length === 0 && <Typography className="overview-empty">No employee data found.</Typography>}
        </Box>
      </Box>
    </CardContent>
  </Card>
}

export default function AdminOverview() {
  const [data, setData] = useState<OverviewData>(emptyData)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  const loadOverview = useCallback(async () => {
    setLoading(true)
    setError('')
    try {
      const [usersResponse, employees, requestsResponse, attendance, departmentsResponse] = await Promise.all([
        getUsers(), getEmployees(), getAttendanceExceptions(), getAttendanceRecords(), getDepartments(),
      ])
      setData({ users: usersResponse.data ?? [], employees, requests: requestsResponse.data ?? [], attendance, departments: departmentsResponse.data ?? [] })
    } catch (loadError) {
      setError(loadError instanceof Error ? loadError.message : 'Could not load the admin overview.')
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => { void loadOverview() }, [loadOverview])

  const pendingRequests = data.requests.filter(({ attendance_exception: request }) =>
    request.request_type === 'regularization'
      ? request.status === 'pending'
      : ['pending', 'partially_approved'].includes(request.status),
  ).length
  const metrics = [
    { label: 'Total users', value: data.users.length, note: `${data.employees.length} employee records`, Icon: GroupsRoundedIcon },
    { label: 'Employee records', value: data.employees.length, note: 'Linked to user accounts', Icon: BadgeRoundedIcon },
    { label: 'Pending requests', value: pendingRequests, note: 'Leaves and regularizations', Icon: EventBusyRoundedIcon },
    { label: 'Attendance records', value: data.attendance.length, note: 'Recorded check-ins', Icon: AccessTimeRoundedIcon },
  ]
  const chartItems = [
    { label: 'Users', value: data.users.length },
    { label: 'Employees', value: data.employees.length },
    { label: 'Requests', value: pendingRequests },
    { label: 'Attendance', value: data.attendance.length },
  ]
  const maxChartValue = Math.max(1, ...chartItems.map(({ value }) => value))
  const employeesByDepartment = data.departments.map((department) => ({
    label: department.department_name,
    value: data.employees.filter(({ employee_detail }) => employee_detail.department_id === department.id).length,
  }))
  const unassignedEmployees = data.employees.filter(({ employee_detail }) => !data.departments.some(({ id }) => id === employee_detail.department_id)).length
  if (unassignedEmployees > 0) employeesByDepartment.push({ label: 'Unassigned', value: unassignedEmployees })
  const roleCounts = new Map<string, number>()
  data.employees.forEach((employee) => {
    const role = employee.user?.role_name || 'Unassigned'
    roleCounts.set(role, (roleCounts.get(role) ?? 0) + 1)
  })
  const employeesByRole = [...roleCounts.entries()].map(([label, value]) => ({ label, value }))

  return (
    <Box className="overview-page">
      <DashboardHeader />
      <Box component="main" className="overview-content">
        {/* <Box className="overview-breadcrumb"><span>Workspace</span><span aria-hidden="true">›</span><strong>Admin overview</strong></Box> */}
        <Stack className="overview-heading" direction="row" justifyContent="space-between" alignItems="flex-end" gap={2}>
          <Box><Typography variant="h4" component="h1">Admin overview</Typography><Typography color="text.secondary">Your employee management platform, at a glance.</Typography></Box>
        </Stack>
        {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}

        <Box className="overview-metrics">
          {metrics.map(({ label, value, note, Icon }) => <Card variant="outlined" key={label} className="overview-metric-card">
            <CardContent>
              <Box className="overview-metric-top"><Typography color="text.secondary">{label}</Typography><span><Icon /></span></Box>
              <Typography className="overview-metric-value">{loading ? '—' : value}</Typography>
              <Typography className="overview-metric-note">{note}</Typography>
            </CardContent>
          </Card>)}
        </Box>

        <Box className="overview-panels">
          <Card variant="outlined" className="overview-panel overview-chart-panel">
            <CardContent>
              <Typography className="overview-kicker">PLATFORM SNAPSHOT</Typography>
              <Typography variant="h6" component="h2">Workforce activity</Typography>
              <Box className="overview-chart" role="img" aria-label="Bar chart comparing users, employee records, pending requests, and attendance records">
                {chartItems.map(({ label, value }, index) => <Box className="overview-chart-column" key={label}>
                  <Typography className="overview-chart-value">{loading ? '—' : value}</Typography>
                  <Box className={`overview-chart-bar overview-chart-bar-${index + 1}`} sx={{ height: loading ? '8%' : `${Math.max(value === 0 ? 4 : 12, value / maxChartValue * 100)}%` }} />
                  <Typography className="overview-chart-label">{label}</Typography>
                </Box>)}
              </Box>
              <Box className="overview-panel-footer"><span>Current totals from your admin data</span><strong>Live data</strong></Box>
            </CardContent>
          </Card>

          <EmployeePieChart title="Employees by department" description="Employee records in each department." items={employeesByDepartment} />
          <EmployeePieChart title="Employees by role" description="Employee records grouped by account role." items={employeesByRole} />
        </Box>
      </Box>
    </Box>
  )
}
