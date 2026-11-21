import { useState } from 'react'

const apiBase = import.meta.env.VITE_API_URL

export default function Signin() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [message, setMessage] = useState('')
  const [isError, setIsError] = useState(false)
  const [isSubmitting, setIsSubmitting] = useState(false)

  async function handleSubmit() {
    setMessage('')
    setIsSubmitting(true)
    try {
      const response = await fetch(`${apiBase}/login`, {
        method: 'POST',
        credentials: 'include',
        headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
        body: JSON.stringify({ user: { email, password } }),
      })
      const result = await response.json().catch(() => ({}))

      if (!response.ok) {
        const details = typeof result.error === 'string'
          ? result.error
          : Array.isArray(result.error)
            ? result.error.join(' ')
            : 'We couldn’t sign you in. Check your email and password, then try again.'
        throw new Error(details)
      }

      const authorization = response.headers.get('Authorization')
      if (authorization) {
        sessionStorage.setItem('authToken', authorization)
      }

      const roleName = String(result.user?.role_name ?? '').toLowerCase()
      if (result.user?.id) sessionStorage.setItem('currentUser', JSON.stringify({ ...result.user, status: result.user.status ?? 'active' }))
      if (roleName === 'admin') {
        sessionStorage.setItem('openAdminMenuAfterSignin', 'true')
        window.location.assign('/admin-dashboard')
        return
      }
      if (roleName === 'employee') {
        window.location.assign('/employee-dashboard')
        return
      }
      throw new Error('Your account role does not have a dashboard configured.')

    } catch (error) {
      setIsError(true)
      setMessage(error instanceof Error ? error.message : 'Something went wrong. Please try again.')
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <main className="signup-page">
      <section className="welcome-panel" aria-label="Welcome">
        <a className="brand" href="/" aria-label="QuickInsure home"><img className="auth-logo" src="https://quickinsure.co.in/static/images/quickinsure-logo.svg" alt="QuickInsure" /></a>
        <div className="welcome-copy">
          <p className="eyebrow">Welcome back</p>
          <h1>Your next<br />step starts here.</h1>
          <p className="welcome-description">Sign in to pick up where you left off.</p>
        </div>
        <div className="plant-art" aria-hidden="true"><span className="sun" /><span className="leaf leaf-one" /><span className="leaf leaf-two" /><span className="leaf leaf-three" /><span className="leaf leaf-four" /><span className="plant-stem" /><span className="plant-pot" /></div>
        <p className="panel-note">Your account will be ready when you are.</p>
      </section>

      <section className="form-panel">
        <div className="form-wrap login-wrap">
          <a className="mobile-brand" href="/" aria-label="QuickInsure home"><img className="auth-logo" src="https://quickinsure.co.in/static/images/quickinsure-logo.svg" alt="QuickInsure" /></a>
          <p className="form-kicker">GOOD TO SEE YOU</p>
          <h2>Welcome back</h2>
          <p className="form-intro">Sign in with your email and password.</p>
          <form onSubmit={(event) => { event.preventDefault(); void handleSubmit() }}>
            <label htmlFor="login-email">Email address</label>
            <input id="login-email" name="email" type="email" autoComplete="email" placeholder="you@example.com" value={email} onChange={(event) => setEmail(event.target.value)} required />
            <label htmlFor="login-password">Password</label>
            <input id="login-password" name="password" type="password" autoComplete="current-password" placeholder="Enter your password" value={password} onChange={(event) => setPassword(event.target.value)} required />
            {message && <p className={`form-message ${isError ? 'error' : 'success'}`} role="status">{message}</p>}
            <button type="submit" disabled={isSubmitting}>{isSubmitting ? 'Signing in…' : 'Sign in'}{!isSubmitting && <span aria-hidden="true">→</span>}</button>
          </form>
          <p className="signin-prompt">New to QuickInsure? <a href="/signup">Create an account</a></p>
        </div>
      </section>
    </main>
  )
}
