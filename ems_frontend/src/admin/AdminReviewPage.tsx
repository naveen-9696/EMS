import { useEffect, useState } from 'react'
import DashboardHeader from '../dashboard/DashboardHeader'
import {
  type AdminUser,
  type AttendanceExceptionItem,
  getAttendanceExceptions,
  getUsers,
  updateLeaveStatus,
  updateRegularizationStatus,
  updateUser,
} from './adminApi'

export type AdminReviewType = 'leaves' | 'regularizations' | 'users'

const pageDetails: Record<AdminReviewType, { title: string; description: string }> = {
  leaves: { title: 'Pending leaves', description: 'Review leave requests and update their status.' },
  regularizations: { title: 'Pending regularizations', description: 'Review attendance corrections and update their status.' },
  users: { title: 'New user verification', description: 'Review new user details and update their account information.' },
}

export default function AdminReviewPage({ type }: { type: AdminReviewType }) {
  const [exceptions, setExceptions] = useState<AttendanceExceptionItem[]>([])
  const [users, setUsers] = useState<AdminUser[]>([])
  const [loading, setLoading] = useState(true)
  const [workingId, setWorkingId] = useState('')
  const [error, setError] = useState('')
  const [notice, setNotice] = useState('')

  useEffect(() => {
    let active = true
    setLoading(true)
    setError('')

    const load = type === 'users'
      ? getUsers().then((response) => { if (active) setUsers((response.data ?? []).filter((user) => user.phase === 'new')) })
      : getAttendanceExceptions().then((response) => {
          if (active) {
            const requestType = type === 'leaves' ? 'leave' : 'regularization'
            setExceptions((response.data ?? []).filter(({ attendance_exception }) => attendance_exception.request_type === requestType && (attendance_exception.status === 'pending' || (type === 'leaves' && attendance_exception.status === 'partially_approved'))))
          }
        })

    load.catch((loadError) => { if (active) setError(loadError instanceof Error ? loadError.message : 'Could not load records.') })
      .finally(() => { if (active) setLoading(false) })
    return () => { active = false }
  }, [type])

  async function decideException(item: AttendanceExceptionItem, status: 'approved' | 'rejected') {
    const record = item.attendance_exception
    setWorkingId(record.id)
    setError('')
    setNotice('')
    try {
      if (type === 'leaves') {
        await updateLeaveStatus(record.id, status, item.leave_dates ?? [])
      } else {
        await updateRegularizationStatus(record.id, status)
      }
      setExceptions((current) => current.filter(({ attendance_exception }) => attendance_exception.id !== record.id))
      setNotice(`Request ${status}.`)
    } catch (actionError) {
      setError(actionError instanceof Error ? actionError.message : 'Could not update this request.')
    } finally {
      setWorkingId('')
    }
  }

  async function saveUser(user: AdminUser) {
    setWorkingId(user.id)
    setError('')
    setNotice('')
    try {
      await updateUser(user)
      if (user.phase !== 'new') setUsers((current) => current.filter((entry) => entry.id !== user.id))
      setNotice('User details updated.')
    } catch (saveError) {
      setError(saveError instanceof Error ? saveError.message : 'Could not update this user.')
    } finally {
      setWorkingId('')
    }
  }

  function editUser(id: string, field: 'name' | 'email' | 'phase' | 'status', value: string) {
    setUsers((current) => current.map((user) => user.id === id ? { ...user, [field]: value } : user))
  }

  const details = pageDetails[type]

  return (
    <main className="dashboard-page">
      <DashboardHeader />
      <section className="admin-review-content">
        <a className="admin-back-link" href="/admin-dashboard">← Admin dashboard</a>
        <p className="form-kicker">REVIEW QUEUE</p>
        <h1>{details.title}</h1>
        <p className="admin-review-intro">{details.description}</p>
        {error && <p className="admin-dashboard-error" role="alert">{error}</p>}
        {notice && <p className="admin-review-notice" role="status">{notice}</p>}
        {loading && <p className="admin-review-empty">Loading…</p>}
        {!loading && type !== 'users' && exceptions.length === 0 && <p className="admin-review-empty">No pending requests.</p>}
        {!loading && type === 'users' && users.length === 0 && <p className="admin-review-empty">No new users are waiting for review.</p>}

        {!loading && type !== 'users' && <div className="admin-review-list">
          {exceptions.map((item) => {
            const request = item.attendance_exception
            return (
              <article className="admin-review-item" key={request.id}>
                <div className="admin-review-item-heading">
                  <div><h2>{item.user?.name || 'User'}</h2><p>{item.user?.email || 'No email provided'}</p></div>
                  <span className="admin-status">Pending</span>
                </div>
                <dl className="admin-request-details">
                  <div><dt>Date</dt><dd>{request.start_date}{request.end_date !== request.start_date ? ` – ${request.end_date}` : ''}</dd></div>
                  <div><dt>Reason</dt><dd>{request.reason || '—'}</dd></div>
                  {type === 'regularizations' && <div><dt>Requested time</dt><dd>{request.checkin_time || '—'} – {request.checkout_time || '—'}</dd></div>}
                </dl>
                <div className="admin-review-actions">
                  <button type="button" className="approve-button" disabled={workingId === request.id} onClick={() => void decideException(item, 'approved')}>{workingId === request.id ? 'Updating…' : 'Approve'}</button>
                  <button type="button" className="reject-button" disabled={workingId === request.id} onClick={() => void decideException(item, 'rejected')}>Reject</button>
                </div>
              </article>
            )
          })}
        </div>}

        {!loading && type === 'users' && <div className="admin-review-list">
          {users.map((user) => (
            <article className="admin-review-item admin-user-item" key={user.id}>
              <div className="admin-review-item-heading"><div><h2>{user.name}</h2><p>Awaiting verification</p></div><span className="admin-status">New</span></div>
              <div className="admin-user-fields">
                <label>Name<input value={user.name} onChange={(event) => editUser(user.id, 'name', event.target.value)} /></label>
                <label>Email<input type="email" value={user.email} onChange={(event) => editUser(user.id, 'email', event.target.value)} /></label>
                <label>Phase<select value={user.phase ?? 'new'} onChange={(event) => editUser(user.id, 'phase', event.target.value)}><option value="new">New</option><option value="intern">Intern</option><option value="probation">Probation</option><option value="permanent">Permanent</option><option value="resigned">Resigned</option></select></label>
                <label>Status<select value={user.status ?? 'active'} onChange={(event) => editUser(user.id, 'status', event.target.value)}><option value="active">Active</option><option value="inactive">Inactive</option></select></label>
              </div>
              <div className="admin-review-actions"><button type="button" className="approve-button" disabled={workingId === user.id} onClick={() => void saveUser(user)}>{workingId === user.id ? 'Saving…' : 'Save user details'}</button></div>
            </article>
          ))}
        </div>}
      </section>
    </main>
  )
}
