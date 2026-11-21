import { useEffect, useState } from 'react'
import DashboardHeader from '../dashboard/DashboardHeader'
import { generateSalary, getEmployees, getSalaryRecords, type AdminEmployee, type SalaryRecord } from './adminApi'

const currency = new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 0 })
const monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']

export default function AdminSalariesPage() {
  const today = new Date()
  const [employees, setEmployees] = useState<AdminEmployee[]>([])
  const [records, setRecords] = useState<SalaryRecord[]>([])
  const [employeeId, setEmployeeId] = useState('')
  const [month, setMonth] = useState(String(today.getMonth() + 1))
  const [year, setYear] = useState(String(today.getFullYear()))
  const [loading, setLoading] = useState(true)
  const [isGenerating, setIsGenerating] = useState(false)
  const [error, setError] = useState('')
  const [notice, setNotice] = useState('')

  async function loadData() {
    setLoading(true)
    setError('')
    try {
      const [employeeResponse, salaryResponse] = await Promise.all([getEmployees(), getSalaryRecords()])
      setEmployees(employeeResponse)
      setRecords(salaryResponse.data ?? [])
      if (!employeeId && employeeResponse[0]) setEmployeeId(employeeResponse[0].employee_detail.id)
    } catch (loadError) {
      setError(loadError instanceof Error ? loadError.message : 'Could not load salary records.')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => { void loadData() }, [])

  async function handleGenerate() {
    if (!employeeId) {
      setError('Select an employee before generating a salary record.')
      return
    }
    setIsGenerating(true)
    setError('')
    setNotice('')
    try {
      await generateSalary(employeeId, Number(month), Number(year))
      setNotice('Salary record generated.')
      await loadData()
    } catch (generationError) {
      setError(generationError instanceof Error ? generationError.message : 'Could not generate this salary record.')
    } finally {
      setIsGenerating(false)
    }
  }

  const employeeNames = new Map(employees.map(({ employee_detail, user }) => [employee_detail.id, user?.name || employee_detail.user_id]))

  return (
    <main className="dashboard-page">
      <DashboardHeader />
      <section className="admin-review-content">
        <a className="admin-back-link" href="/admin-dashboard">← Admin dashboard</a>
        <p className="form-kicker">PAYROLL</p>
        <h1>Salary records</h1>
        <p className="admin-review-intro">Review salary history and generate a monthly salary record.</p>
        {error && <p className="admin-dashboard-error" role="alert">{error}</p>}
        {notice && <p className="admin-review-notice" role="status">{notice}</p>}

        <section className="admin-review-item admin-salary-generator">
          <h2>Generate salary</h2>
          <div className="admin-user-fields salary-generator-fields">
            <label>Employee<select value={employeeId} onChange={(event) => setEmployeeId(event.target.value)}><option value="">Select employee</option>{employees.map(({ employee_detail, user }) => <option key={employee_detail.id} value={employee_detail.id}>{user?.name || employee_detail.user_id}</option>)}</select></label>
            <label>Month<select value={month} onChange={(event) => setMonth(event.target.value)}>{monthNames.map((name, index) => <option key={name} value={index + 1}>{name}</option>)}</select></label>
            <label>Year<input type="number" min="1" max={today.getFullYear()} value={year} onChange={(event) => setYear(event.target.value)} /></label>
          </div>
          <div className="admin-review-actions"><button type="button" className="approve-button" disabled={isGenerating || employees.length === 0} onClick={() => void handleGenerate()}>{isGenerating ? 'Generating…' : 'Generate record'}</button></div>
        </section>

        <div className="admin-salary-list-heading"><h2>Salary history</h2><span>{records.length} records</span></div>
        {loading && <p className="admin-review-empty">Loading salary history…</p>}
        {!loading && records.length === 0 && <p className="admin-review-empty">No salary records found.</p>}
        <div className="admin-review-list">
          {records.map((record) => <article className="admin-review-item" key={record.id}>
            <div className="admin-review-item-heading"><div><h2>{employeeNames.get(record.employee_detail_id) || 'Employee'}</h2><p>{monthNames[record.month - 1]} {record.year}</p></div><strong className="salary-total">{currency.format(record.payable_salary)}</strong></div>
            <dl className="admin-request-details">
              <div><dt>Base salary</dt><dd>{currency.format(record.base_salary)}</dd></div>
              <div><dt>Present days</dt><dd>{record.present_days}</dd></div>
              <div><dt>Approved leave days</dt><dd>{record.approved_leave_days}</dd></div>
              <div><dt>Paid leave days</dt><dd>{record.paid_leave_days}</dd></div>
              <div><dt>Adjustments</dt><dd>{currency.format(record.salary_adjustments)}</dd></div>
            </dl>
          </article>)}
        </div>
      </section>
    </main>
  )
}
