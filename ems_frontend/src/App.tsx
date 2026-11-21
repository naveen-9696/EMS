import Signin from './authentication/Signin'
import Signout from './authentication/Signout'
import Signup from './authentication/Signup'
import AdminDashboard from './admin/AdminDashboard'
import AdminOverview from './admin/AdminOverview'
import AdminReviewPage from './admin/AdminReviewPage'
import AdminEmployeesPage from './admin/AdminEmployeesPage'
import AdminSalariesPage from './admin/AdminSalariesPage'
import AdminAttendancePage from './admin/AdminAttendancePage'
import EmployeeDashboard from './employee/EmployeeDashboard'
import './App.css'

function App() {
  const path = window.location.pathname
  if (path === '/' || path === '/signup') return <Signup />
  if (path === '/login') return <Signin />
  if (path === '/signout') return <Signout />
  if (path === '/admin-dashboard') return <AdminDashboard />
  if (path === '/admin/overview') return <AdminOverview />
  if (path === '/admin/pending-leaves') return <AdminReviewPage type="leaves" />
  if (path === '/admin/pending-regularizations') return <AdminReviewPage type="regularizations" />
  if (path === '/admin/users') return <AdminReviewPage type="users" />
  if (path === '/admin/employees') return <AdminEmployeesPage />
  if (path === '/admin/salaries') return <AdminSalariesPage />
  if (path === '/admin/attendance') return <AdminAttendancePage />
  if (path === '/employee-dashboard') return <EmployeeDashboard />
}

export default App
