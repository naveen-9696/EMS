import DashboardHeader from '../dashboard/DashboardHeader'

export default function EmployeeDashboard() {
  return (
    <main className="dashboard-page">
      <DashboardHeader />
      <section className="dashboard-content">
        <p className="form-kicker">EMPLOYEE</p>
        <h1>Employee dashboard</h1>
        <p>Welcome to your employee workspace.</p>
      </section>
    </main>
  )
}
