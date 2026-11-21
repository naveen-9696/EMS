import { useState } from 'react'

const apiBase = import.meta.env.VITE_API_URL 

export default function Signup() {
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [passwordConfirmation, setPasswordConfirmation] = useState('')
  const [message, setMessage] = useState('')
  const [isError, setIsError] = useState(false)
  const [isSubmitting, setIsSubmitting] = useState(false)

  async function handleSubmit() {
    setMessage('')
    if (password !== passwordConfirmation) {
      setIsError(true)
      setMessage('Your passwords don’t match. Please try again.')
      return
    }

    setIsSubmitting(true)
    try {
      const response = await fetch(`${apiBase}/signup`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
        body: JSON.stringify({ name, email, password, password_confirmation: passwordConfirmation }),
      })
      const result = await response.json().catch(() => ({}))

      if (!response.ok) {
        const errors = result.errors
        const details = Array.isArray(errors)
          ? errors.join(' ')
          : errors && typeof errors === 'object'
            ? Object.values(errors).flat().join(' ')
            : 'We couldn’t create your account. Please check your details and try again.'
        throw new Error(details)
      }

      setIsError(false)
      setMessage('Your account is ready. Welcome aboard!')
      setName('')
      setEmail('')
      setPassword('')
      setPasswordConfirmation('')
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
          <p className="eyebrow">A little room to grow</p>
          <h1>Good things<br />start here.</h1>
          <p className="welcome-description">Create your account and make space for what’s next.</p>
        </div>
        <div className="plant-art" aria-hidden="true"><span className="sun" /><span className="leaf leaf-one" /><span className="leaf leaf-two" /><span className="leaf leaf-three" /><span className="leaf leaf-four" /><span className="plant-stem" /><span className="plant-pot" /></div>
        <p className="panel-note">Small steps. Fresh starts. Room to grow.</p>
      </section>

      <section className="form-panel">
        <div className="form-wrap">
          <a className="mobile-brand" href="/" aria-label="QuickInsure home"><img className="auth-logo" src="https://quickinsure.co.in/static/images/quickinsure-logo.svg" alt="QuickInsure" /></a>
          <p className="form-kicker">GET STARTED</p>
          <h2>Create your account</h2>
          <p className="form-intro">It only takes a minute. Let’s get you set up.</p>
          <form onSubmit={(event) => { event.preventDefault(); void handleSubmit() }}>
            <label htmlFor="name">Full name</label>
            <input id="name" name="name" type="text" autoComplete="name" placeholder="e.g. Alex Morgan" value={name} onChange={(event) => setName(event.target.value)} required />
            <label htmlFor="email">Email address</label>
            <input id="email" name="email" type="email" autoComplete="email" placeholder="you@example.com" value={email} onChange={(event) => setEmail(event.target.value)} required />
            <div className="password-label-row"><label htmlFor="password">Password</label><span>At least 8 characters</span></div>
            <input id="password" name="password" type="password" autoComplete="new-password" placeholder="Create a password" minLength={8} value={password} onChange={(event) => setPassword(event.target.value)} required />
            <label htmlFor="password-confirmation">Confirm password</label>
            <input id="password-confirmation" name="password_confirmation" type="password" autoComplete="new-password" placeholder="Enter your password again" minLength={8} value={passwordConfirmation} onChange={(event) => setPasswordConfirmation(event.target.value)} required />
            {message && <p className={`form-message ${isError ? 'error' : 'success'}`} role="status">{message}</p>}
            <button type="submit" disabled={isSubmitting}>{isSubmitting ? 'Creating your account…' : 'Create account'}{!isSubmitting && <span aria-hidden="true">→</span>}</button>
          </form>
          <p className="signin-prompt">Already have an account? <a href="/login">Sign in</a></p>
          <p className="terms-note">By creating an account, you agree to our <a href="/terms">Terms</a> and <a href="/privacy">Privacy Policy</a>.</p>
        </div>
      </section>
    </main>
  )
}
