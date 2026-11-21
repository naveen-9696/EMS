import { useEffect, useRef, useState } from 'react'
import { MenuItem, TextField } from '@mui/material'
import DashboardHeader from '../dashboard/DashboardHeader'
import { createEmployee, deleteEmployee, getDepartments, getEmployees, getUsers, updateEmployee, updateUser, type AdminEmployee, type AdminUser, type DepartmentOption } from './adminApi'

const designations = ['Junior Software Engineer', 'Software Engineer', 'Senior Software Engineer', 'Full Stack Developer', 'DevOps Engineer']

export default function AdminEmployeesPage() {
  const [employees, setEmployees] = useState<AdminEmployee[]>([])
  const [users, setUsers] = useState<AdminUser[]>([])
  const [departments, setDepartments] = useState<DepartmentOption[]>([])
  const [showCreate, setShowCreate] = useState(false)
  const [newUserId, setNewUserId] = useState('')
  const [departmentId, setDepartmentId] = useState('')
  const [designation, setDesignation] = useState(designations[0])
  const [baseSalary, setBaseSalary] = useState('')
  const [loading, setLoading] = useState(true)
  const [workingId, setWorkingId] = useState('')
  const [editingUserId, setEditingUserId] = useState('')
  const [editingUserOriginal, setEditingUserOriginal] = useState<AdminUser | null>(null)
  const [editingEmployeeId, setEditingEmployeeId] = useState('')
  const [editingEmployeeOriginal, setEditingEmployeeOriginal] = useState<AdminEmployee | null>(null)
  const [error, setError] = useState('')
  const [notice, setNotice] = useState('')
  const [searchInput, setSearchInput] = useState('')
  const [searchTerm, setSearchTerm] = useState('')
  const createFormRef = useRef<HTMLElement | null>(null)

  async function loadData() {
    setLoading(true)
    setError('')
    try {
      const [employeeResponse, userResponse, departmentResponse] = await Promise.all([getEmployees(), getUsers(), getDepartments()])
      setEmployees(employeeResponse)
      setDepartments(departmentResponse.data ?? [])
      setUsers(userResponse.data ?? [])
    } catch (loadError) {
      setError(loadError instanceof Error ? loadError.message : 'Could not load employees.')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => { void loadData() }, [])

  const userRecords = users.filter((user) => user.role_name?.toLowerCase() !== 'admin')
  const filteredUsers = userRecords.filter((user) => {
    const employee = employees.find(({ employee_detail }) => employee_detail.user_id === user.id)
    const department = departments.find(({ id }) => id === employee?.employee_detail.department_id)?.department_name || ''
    const searchableText = [user.name, user.email, department, user.role_name || employee?.user?.role_name || '']
      .join(' ')
      .toLocaleLowerCase()
    return searchableText.includes(searchTerm.toLocaleLowerCase())
  })

  function editEmployee(id: string, field: 'department_id' | 'designation' | 'base_salary', value: string) {
    setEmployees((current) => current.map((item) => item.employee_detail.id === id
      ? { ...item, employee_detail: { ...item.employee_detail, [field]: field === 'base_salary' ? Number(value) : value } }
      : item))
  }

  function editUser(id: string, field: 'name' | 'email' | 'phase' | 'status', value: string) {
    setUsers((current) => current.map((user) => user.id === id ? { ...user, [field]: value } : user))
  }

  async function saveUser(user: AdminUser) {
    setWorkingId(user.id)
    setError('')
    setNotice('')
    try {
      await updateUser(user)
      setEditingUserId('')
      setEditingUserOriginal(null)
      setNotice(`Updated ${user.name}’s user details.`)
    } catch (saveError) {
      setError(saveError instanceof Error ? saveError.message : 'Could not update this user.')
    } finally {
      setWorkingId('')
    }
  }

  async function saveEmployee(employee: AdminEmployee) {
    const { id, ...values } = employee.employee_detail
    setWorkingId(id)
    setError('')
    setNotice('')
    try {
      await updateEmployee({ id, ...values })
      setEditingEmployeeId('')
      setEditingEmployeeOriginal(null)
      setNotice(`Updated ${employee.user?.name || 'employee'}’s details.`)
    } catch (saveError) {
      setError(saveError instanceof Error ? saveError.message : 'Could not update this employee.')
    } finally {
      setWorkingId('')
    }
  }

  async function removeEmployee(employee: AdminEmployee) {
    const id = employee.employee_detail.id
    setWorkingId(id)
    setError('')
    setNotice('')
    try {
      await deleteEmployee(id)
      setEmployees((current) => current.filter((item) => item.employee_detail.id !== id))
      if (editingEmployeeId === id) {
        setEditingEmployeeId('')
        setEditingEmployeeOriginal(null)
      }
      setNotice('Employee record deleted.')
    } catch (deleteError) {
      setError(deleteError instanceof Error ? deleteError.message : 'Could not delete this employee record.')
    } finally {
      setWorkingId('')
    }
  }

  async function handleCreate() {
    if (!newUserId || !departmentId || !baseSalary) {
      setError('Choose a user and provide a department ID and base salary.')
      return
    }
    setWorkingId('create')
    setError('')
    setNotice('')
    try {
      await createEmployee({ user_id: newUserId, department_id: departmentId, designation, base_salary: Number(baseSalary) })
      setNotice('Employee record created.')
      setShowCreate(false)
      setNewUserId('')
      setDepartmentId('')
      setBaseSalary('')
      await loadData()
    } catch (createError) {
      setError(createError instanceof Error ? createError.message : 'Could not create this employee record.')
    } finally {
      setWorkingId('')
    }
  }

  function startEmployeeCreate(userId: string) {
    setNewUserId(userId)
    setError('')
    setShowCreate(true)
    requestAnimationFrame(() => createFormRef.current?.scrollIntoView({ behavior: 'smooth', block: 'center' }))
  }

  return (
    <main className="dashboard-page">
      <DashboardHeader />
      <section className="admin-review-content">
        <a className="admin-back-link" href="/admin-dashboard">← Admin dashboard</a>
        <p className="form-kicker">PEOPLE</p>
        <div className="admin-page-title-row"><div><h1>User details</h1><p className="admin-review-intro">View every user and their related employee record in one place.</p></div></div>
        {error && !showCreate && <p className="admin-dashboard-error" role="alert">{error}</p>}
        {notice && <p className="admin-review-notice" role="status">{notice}</p>}
        <form className="admin-search-row" onSubmit={(event) => { event.preventDefault(); setSearchTerm(searchInput.trim()) }}>
          <label htmlFor="user-search">Search users</label>
          <input id="user-search" type="search" value={searchInput} onChange={(event) => setSearchInput(event.target.value)} placeholder="Name, email, department, or role" />
          <button className="admin-primary-action" type="submit">Search</button>
          {searchTerm && <button className="reject-button" type="button" onClick={() => { setSearchInput(''); setSearchTerm('') }}>Clear</button>}
        </form>
        {showCreate && <section ref={createFormRef} className="admin-review-item admin-create-form">
          <h2>Add employee record</h2>
          {error && <p className="admin-dashboard-error" role="alert">{error}</p>}
          <div className="admin-user-fields">
            <TextField select fullWidth label="User" size="small" value={newUserId} onChange={(event) => setNewUserId(event.target.value)}>
              <MenuItem value="" disabled>Select a user</MenuItem>
              {userRecords.filter((user) => !employees.some(({ employee_detail }) => employee_detail.user_id === user.id)).map((user) => <MenuItem key={user.id} value={user.id}>{user.name} · {user.email}</MenuItem>)}
            </TextField>
            <TextField select fullWidth label="Department" size="small" value={departmentId} onChange={(event) => setDepartmentId(event.target.value)}>
              <MenuItem value="" disabled>Select department</MenuItem>
              {departments.map((department) => <MenuItem key={department.id} value={department.id}>{department.department_name}</MenuItem>)}
            </TextField>
            <TextField select fullWidth label="Designation" size="small" value={designation} onChange={(event) => setDesignation(event.target.value)}>
              {designations.map((item) => <MenuItem key={item} value={item}>{item}</MenuItem>)}
            </TextField>
            <TextField fullWidth label="Base salary" type="number" size="small" inputProps={{ min: 0 }} value={baseSalary} onChange={(event) => setBaseSalary(event.target.value)} />
          </div>
          <div className="admin-review-actions"><button type="button" className="approve-button" disabled={workingId === 'create' || userRecords.every((user) => employees.some(({ employee_detail }) => employee_detail.user_id === user.id)) || departments.length === 0} onClick={() => void handleCreate()}>{workingId === 'create' ? 'Creating…' : 'Create employee'}</button><button type="button" className="reject-button" disabled={workingId === 'create'} onClick={() => { setShowCreate(false); setNewUserId(''); setError('') }}>Cancel</button></div>
          {userRecords.every((user) => employees.some(({ employee_detail }) => employee_detail.user_id === user.id)) && <p className="admin-field-note">All users already have employee records.</p>}
          {departments.length === 0 && <p className="admin-field-note">No departments are available.</p>}
        </section>}
        {loading && <p className="admin-review-empty">Loading employee records…</p>}
        {!loading && userRecords.length === 0 && <p className="admin-review-empty">No users found.</p>}
        {!loading && userRecords.length > 0 && filteredUsers.length === 0 && <p className="admin-review-empty">No users match “{searchTerm}”.</p>}
        <div className="admin-review-list">
          {filteredUsers.map((user) => {
            const employee = employees.find(({ employee_detail }) => employee_detail.user_id === user.id)
            const detail = employee?.employee_detail
            const isEditingUser = editingUserId === user.id
            const isEditingEmployee = Boolean(detail && editingEmployeeId === detail.id)
            return <article className="admin-review-item" key={user.id}>
              <div className="admin-review-item-heading"><div><h2>{user.name || 'User'}</h2><p>{user.email}</p></div><div className="admin-review-actions"><span className="admin-status">{user.status || 'Active'} · {user.phase || 'No phase'}</span>{isEditingUser ? <><button className="approve-button" disabled={workingId === user.id} onClick={() => void saveUser(user)}>{workingId === user.id ? 'Saving…' : 'Save user'}</button><button className="reject-button" disabled={workingId === user.id} onClick={() => { if (editingUserOriginal) setUsers((current) => current.map((entry) => entry.id === user.id ? editingUserOriginal : entry)); setEditingUserId(''); setEditingUserOriginal(null) }}>Cancel</button></> : <button className="reject-button" onClick={() => { setEditingUserOriginal({ ...user }); setEditingUserId(user.id) }}>Edit</button>}</div></div>
              {isEditingUser && <div className="admin-user-fields">
                <label>Name<input value={user.name} onChange={(event) => editUser(user.id, 'name', event.target.value)} /></label>
                <label>Email<input type="email" value={user.email} onChange={(event) => editUser(user.id, 'email', event.target.value)} /></label>
                <label>Phase<select value={user.phase ?? ''} onChange={(event) => editUser(user.id, 'phase', event.target.value)}><option value="">No phase</option><option value="new">New</option><option value="intern">Intern</option><option value="probation">Probation</option><option value="permanent">Permanent</option><option value="resigned">Resigned</option></select></label>
                <label>Status<select value={user.status ?? ''} onChange={(event) => editUser(user.id, 'status', event.target.value)}><option value="">No status</option><option value="active">Active</option><option value="inactive">Inactive</option></select></label>
              </div>}
              {detail && employee ? <>
                <div className="admin-review-item-heading"><div><h3>Employee record</h3></div><div className="admin-review-actions">{isEditingEmployee ? <><button className="approve-button" disabled={workingId === detail.id} onClick={() => void saveEmployee(employee)}>{workingId === detail.id ? 'Saving…' : 'Save employee'}</button><button className="reject-button" disabled={workingId === detail.id} onClick={() => { if (editingEmployeeOriginal) setEmployees((current) => current.map((entry) => entry.employee_detail.id === detail.id ? editingEmployeeOriginal : entry)); setEditingEmployeeId(''); setEditingEmployeeOriginal(null) }}>Cancel</button></> : <button className="reject-button" onClick={() => { setEditingEmployeeOriginal({ ...employee, employee_detail: { ...employee.employee_detail } }); setEditingEmployeeId(detail.id) }}>Edit employee</button>}<button className="reject-button" disabled={workingId === detail.id} onClick={() => void removeEmployee(employee)}>Delete record</button></div></div>
                <div className="admin-user-fields">
                  <label>Department{isEditingEmployee ? <select value={detail.department_id} onChange={(event) => editEmployee(detail.id, 'department_id', event.target.value)}>{departments.map((department) => <option key={department.id} value={department.id}>{department.department_name}</option>)}</select> : <span>{departments.find((department) => department.id === detail.department_id)?.department_name || detail.department_id}</span>}</label>
                  <label>Designation{isEditingEmployee ? <select value={detail.designation} onChange={(event) => editEmployee(detail.id, 'designation', event.target.value)}>{designations.map((item) => <option key={item}>{item}</option>)}</select> : <span>{detail.designation}</span>}</label>
                  <label>Base salary{isEditingEmployee ? <input type="number" min="0" value={detail.base_salary} onChange={(event) => editEmployee(detail.id, 'base_salary', event.target.value)} /> : <span>{detail.base_salary}</span>}</label>
                </div>
              </> : <div className="admin-review-actions"><button type="button" className="approve-button" onClick={() => startEmployeeCreate(user.id)}>Add employee details</button></div>}
            </article>
          })}
        </div>
      </section>
    </main>
  )
}
