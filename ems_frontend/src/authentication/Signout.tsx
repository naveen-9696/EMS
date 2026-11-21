import { useState } from 'react'
import { signoutUser } from './signoutUser'

export default function Signout() {
  const [message, setMessage] = useState('')
  const [isError, setIsError] = useState(false)
  const [isSubmitting, setIsSubmitting] = useState(false)

  async function handleSignout() {
    setIsSubmitting(true)
    setMessage('')

    try {
      await signoutUser()
      window.location.assign('/login')
    } catch (error) {
      setIsError(true)
      setMessage(error instanceof Error ? error.message : 'Something went wrong. Please try again.')
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <main className="signup-page">
      <section className="welcome-panel" aria-label="QuickInsure">
        <a className="brand" href="/" aria-label="QuickInsure home"><span className="brand-mark" aria-hidden="true">Q</span><span>QuickInsure</span></a>
        <div className="welcome-copy">
          <p className="eyebrow">Until next time</p>
          <h1>Thanks for<br />stopping by.</h1>
          <p className="welcome-description">Your account will be here when you’re ready to return.</p>
        </div>
        <div className="plant-art" aria-hidden="true"><span className="sun" /><span className="leaf leaf-one" /><span className="leaf leaf-two" /><span className="leaf leaf-three" /><span className="leaf leaf-four" /><span className="plant-stem" /><span className="plant-pot" /></div>
        <p className="panel-note">Take care, and see you again soon.</p>
      </section>

      <section className="form-panel">
        <div className="form-wrap login-wrap">
          <div className="mobile-brand" aria-hidden="true"><span className="brand-mark">Q</span><span>QuickInsure</span></div>
          <p className="form-kicker">SIGNING OUT</p>
          <h2>Ready to leave?</h2>
          <p className="form-intro">You can sign back in whenever you’re ready.</p>
          {message && <p className={`form-message ${isError ? 'error' : 'success'}`} role="status">{message}</p>}
          <button className="standalone-button" type="button" onClick={() => void handleSignout()} disabled={isSubmitting}>
            {isSubmitting ? 'Signing out…' : 'Sign out'}{!isSubmitting && <span aria-hidden="true">→</span>}
          </button>
          <p className="signin-prompt"><a href="/login">Back to sign in</a></p>
        </div>
      </section>
    </main>
  )
}
