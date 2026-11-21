const apiBase = import.meta.env.VITE_API_URL

export async function signoutUser() {
  const authToken = sessionStorage.getItem('authToken')
  const response = await fetch(`${apiBase}/logout`, {
    method: 'DELETE',
    credentials: 'include',
    headers: {
      Accept: 'application/json',
      ...(authToken ? { Authorization: authToken } : {}),
    },
  })
  const result = await response.json().catch(() => ({}))

  if (!response.ok) {
    throw new Error(typeof result.error === 'string' ? result.error : 'We couldn’t sign you out. Please try again.')
  }

  sessionStorage.removeItem('authToken')
  sessionStorage.removeItem('currentUser')
  sessionStorage.removeItem('dashboardMenuOpen')
}
