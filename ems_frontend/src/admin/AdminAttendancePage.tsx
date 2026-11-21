import { useEffect, useMemo, useState, type FormEvent } from 'react'
import { Box, Button, MenuItem, TextField, Typography } from '@mui/material'
import DashboardHeader from '../dashboard/DashboardHeader'
import { getAttendanceRecords, getEmployees, updateAttendance, type AdminEmployee, type AttendanceItem } from './adminApi'

const monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
const weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']

function toLocalDateTime(value: string | null) {
  if (!value) return ''
  const date = new Date(value)
  return new Date(date.getTime() - date.getTimezoneOffset() * 60_000).toISOString().slice(0, 16)
}

function toIsoDateTime(value: string | null) {
  return value ? new Date(value).toISOString() : null
}

function dateKey(date: Date) {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
}

function hoursWorked(records: AttendanceItem[]) {
  const now = new Date()
  const totalMilliseconds = records.reduce((total, item) => {
    const start = new Date(item.attendance_record.checkin_time)
    const end = item.attendance_record.checkout_time
      ? new Date(item.attendance_record.checkout_time)
      : dateKey(start) === dateKey(now) ? now : start
    return total + Math.max(0, end.getTime() - start.getTime())
  }, 0)
  return totalMilliseconds / 3_600_000
}

function MonthCalendar({ month, year, attendanceByDate }: { month: number; year: number; attendanceByDate: Map<string, AttendanceItem[]> }) {
  const firstWeekday = new Date(year, month, 1).getDay()
  const dayCount = new Date(year, month + 1, 0).getDate()
  const calendarCells: (number | null)[] = [
    ...Array.from({ length: firstWeekday }, () => null),
    ...Array.from({ length: dayCount }, (_, index) => index + 1),
  ]
  while (calendarCells.length % 7 !== 0) calendarCells.push(null)

  return <article className="attendance-month-card">
    <h2>{monthNames[month]}</h2>
    <div className="attendance-month-grid attendance-weekdays">{weekDays.map((day) => <span key={day}>{day}</span>)}</div>
    <div className="attendance-month-grid">
      {calendarCells.map((day, index) => {
        if (day === null) return <span className="attendance-day attendance-day-empty" key={`empty-${index}`} />
        const key = dateKey(new Date(year, month, day))
        const dayRecords = attendanceByDate.get(key) ?? []
        const isPresent = dayRecords.length > 0
        const workedHours = hoursWorked(dayRecords)
        const times = dayRecords.map(({ attendance_record: record }) => `${new Date(record.checkin_time).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}${record.checkout_time ? `–${new Date(record.checkout_time).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}` : '–in progress'}`).join(', ')
        return <div className={`attendance-day ${isPresent ? 'attendance-day-present' : 'attendance-day-absent'}`} key={key} title={isPresent ? `${monthNames[month]} ${day}: Present, ${workedHours.toFixed(1)} hours (${times})` : `${monthNames[month]} ${day}: Absent`}>
          <span className="attendance-day-number">{day}</span>
          <span className="attendance-day-status">{isPresent ? 'Present' : 'Absent'}</span>
          {isPresent && <span className="attendance-day-hours">{workedHours.toFixed(1)}h</span>}
        </div>
      })}
    </div>
  </article>
}

export default function AdminAttendancePage() {
  const [records, setRecords] = useState<AttendanceItem[]>([])
  const [employees, setEmployees] = useState<AdminEmployee[]>([])
  const [selectedEmployeeId, setSelectedEmployeeId] = useState('')
  const [employeeSearchInput, setEmployeeSearchInput] = useState('')
  const [employeeSearch, setEmployeeSearch] = useState('')
  const [calendarYear, setCalendarYear] = useState(new Date().getFullYear())
  const [calendarMonth, setCalendarMonth] = useState(new Date().getMonth())
  const [loading, setLoading] = useState(true)
  const [workingId, setWorkingId] = useState('')
  const [error, setError] = useState('')
  const [notice, setNotice] = useState('')

  async function loadPageData() {
    setLoading(true)
    setError('')
    try {
      const [attendanceRecords, employeeRecords] = await Promise.all([getAttendanceRecords(), getEmployees()])
      setRecords(attendanceRecords)
      setEmployees(employeeRecords)
      setSelectedEmployeeId((current) => current || employeeRecords[0]?.employee_detail.id || '')
    } catch (loadError) {
      setError(loadError instanceof Error ? loadError.message : 'Could not load attendance records.')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => { void loadPageData() }, [])

  const matchingEmployees = useMemo(() => {
    const query = employeeSearch.toLocaleLowerCase()
    return employees.filter(({ user }) => `${user?.name ?? ''} ${user?.email ?? ''}`.toLocaleLowerCase().includes(query))
  }, [employeeSearch, employees])
  const selectedEmployee = employees.find(({ employee_detail }) => employee_detail.id === selectedEmployeeId)
  const selectedRecords = records.filter(({ attendance_record }) => attendance_record.employee_detail_id === selectedEmployeeId)
  const attendanceByDate = new Map<string, AttendanceItem[]>()
  selectedRecords.forEach((item) => {
    const key = dateKey(new Date(item.attendance_record.checkin_time))
    attendanceByDate.set(key, [...(attendanceByDate.get(key) ?? []), item])
  })

  function searchEmployees(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    const query = employeeSearchInput.trim()
    const results = employees.filter(({ user }) => `${user?.name ?? ''} ${user?.email ?? ''}`.toLocaleLowerCase().includes(query.toLocaleLowerCase()))
    setEmployeeSearch(query)
    setSelectedEmployeeId((current) => results.some(({ employee_detail }) => employee_detail.id === current) ? current : results[0]?.employee_detail.id ?? '')
  }

  function changeYear(offset: number) {
    setCalendarYear((year) => year + offset)
  }

  function editRecord(id: string, field: 'checkin_time' | 'checkout_time', value: string) {
    setRecords((current) => current.map((item) => item.attendance_record.id === id
      ? { ...item, attendance_record: { ...item.attendance_record, [field]: value } }
      : item))
  }

  async function saveRecord(item: AttendanceItem) {
    const record = item.attendance_record
    setWorkingId(record.id)
    setError('')
    setNotice('')
    try {
      await updateAttendance({
        ...record,
        checkin_time: toIsoDateTime(record.checkin_time) || '',
        checkout_time: toIsoDateTime(record.checkout_time),
      })
      setNotice('Attendance record updated.')
      setRecords(await getAttendanceRecords())
    } catch (saveError) {
      setError(saveError instanceof Error ? saveError.message : 'Could not update this attendance record.')
    } finally {
      setWorkingId('')
    }
  }

  return (
    <main className="dashboard-page">
      <DashboardHeader />
      <section className="admin-review-content attendance-page-content">
        <a className="admin-back-link" href="/admin-dashboard">← Admin dashboard</a>
        <p className="form-kicker">TIME &amp; ATTENDANCE</p>
        <h1>Attendance records</h1>
        <p className="admin-review-intro">Search an employee to review their attendance and hours throughout the year.</p>
        {error && <p className="admin-dashboard-error" role="alert">{error}</p>}
        {notice && <p className="admin-review-notice" role="status">{notice}</p>}

        <form className="attendance-search" onSubmit={searchEmployees}>
          <TextField fullWidth label="Search employee" size="small" value={employeeSearchInput} onChange={(event) => setEmployeeSearchInput(event.target.value)} placeholder="Name or email" />
          <Button type="submit" variant="contained">Search</Button>
        </form>
        {!loading && employees.length === 0 && <p className="admin-review-empty">No employee records found.</p>}
        {!loading && employees.length > 0 && matchingEmployees.length === 0 && <p className="admin-review-empty">No employees match that search.</p>}
        {matchingEmployees.length > 0 && <Box className="attendance-filter-row">
          <TextField select fullWidth label="Employee" size="small" value={selectedEmployeeId} onChange={(event) => setSelectedEmployeeId(event.target.value)}>
            {matchingEmployees.map(({ employee_detail, user }) => <MenuItem key={employee_detail.id} value={employee_detail.id}>{user?.name || 'Employee'}{user?.email ? ` · ${user.email}` : ''}</MenuItem>)}
          </TextField>
          <TextField select label="Month" size="small" value={calendarMonth} onChange={(event) => setCalendarMonth(Number(event.target.value))}>
            {monthNames.map((month, index) => <MenuItem key={month} value={index}>{month}</MenuItem>)}
          </TextField>
          <Box className="attendance-year-control"><Button aria-label="Previous year" onClick={() => changeYear(-1)}>‹ Previous year</Button><strong>{calendarYear}</strong><Button aria-label="Next year" onClick={() => changeYear(1)}>Next year ›</Button></Box>
        </Box>}

        {loading && <p className="admin-review-empty">Loading attendance…</p>}
        {!loading && selectedEmployee && <>
          <Box className="attendance-employee-heading"><div><h2>{selectedEmployee.user?.name || 'Employee'}</h2><p>{selectedEmployee.user?.email || selectedEmployee.employee_detail.designation}</p></div><div className="attendance-legend"><span><i className="attendance-legend-present" />Present</span><span><i className="attendance-legend-absent" />Absent</span></div></Box>
          <Box className="attendance-month-view">
            <MonthCalendar key={`${calendarYear}-${calendarMonth}`} month={calendarMonth} year={calendarYear} attendanceByDate={attendanceByDate} />
          </Box>

          <Typography variant="h6" component="h2" sx={{ mt: 4, mb: 2 }}>Attendance entries</Typography>
          {selectedRecords.length === 0 && <p className="admin-review-empty">No attendance entries found for this employee.</p>}
          <div className="admin-review-list">
            {selectedRecords.map((item) => {
              const record = item.attendance_record
              return <article className="admin-review-item" key={record.id}>
                <div className="admin-review-item-heading"><div><h2>{item.user?.name || 'Employee'}</h2><p>{new Date(record.checkin_time).toLocaleDateString()}</p></div></div>
                <div className="admin-user-fields attendance-fields">
                  <label>Check-in<input type="datetime-local" value={toLocalDateTime(record.checkin_time)} onChange={(event) => editRecord(record.id, 'checkin_time', event.target.value)} /></label>
                  <label>Check-out<input type="datetime-local" value={toLocalDateTime(record.checkout_time)} onChange={(event) => editRecord(record.id, 'checkout_time', event.target.value)} /></label>
                </div>
                <div className="admin-review-actions"><button type="button" className="approve-button" disabled={workingId === record.id} onClick={() => void saveRecord(item)}>{workingId === record.id ? 'Saving…' : 'Save attendance'}</button></div>
              </article>
            })}
          </div>
        </>}
      </section>
    </main>
  )
}
