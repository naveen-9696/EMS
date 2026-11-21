import { useEffect, useState } from 'react'
import { Alert, AppBar, Box, Button, Drawer, IconButton, List, ListItemButton, ListItemText, MenuItem, TextField, Toolbar, Typography } from '@mui/material'
import MenuRoundedIcon from '@mui/icons-material/MenuRounded'
import AccountCircleRoundedIcon from '@mui/icons-material/AccountCircleRounded'
import { signoutUser } from '../authentication/signoutUser'
import { getDepartments, getEmployees, updateEmployee, updateUser, type AdminEmployee, type AdminUser, type DepartmentOption } from '../admin/adminApi'

const adminLinks = [
  ['Admin Dashboard', '/admin-dashboard'],
  ['Overview', '/admin/overview'],
  ['All Users', '/admin/employees'],
  ['New User verification', '/admin/users'],
  ['Pending leaves', '/admin/pending-leaves'],
  ['Pending regularizations', '/admin/pending-regularizations'],
  ['Salary records', '/admin/salaries'],
  ['Attendance records', '/admin/attendance'],
]

function getStoredProfile(): AdminUser | null {
  try {
    const storedProfile = sessionStorage.getItem('currentUser')
    return storedProfile ? JSON.parse(storedProfile) as AdminUser : null
  } catch {
    return null
  }
}

export default function DashboardHeader() {
  const [isSigningOut, setIsSigningOut] = useState(false)
  const [error, setError] = useState('')
  const [isMenuOpen, setIsMenuOpen] = useState(() => sessionStorage.getItem('dashboardMenuOpen') === 'true')
  const [profile, setProfile] = useState<AdminUser | null>(getStoredProfile)
  const [isProfileOpen, setIsProfileOpen] = useState(false)
  const [isEditingProfile, setIsEditingProfile] = useState(false)
  const [isLoadingProfileDetails, setIsLoadingProfileDetails] = useState(false)
  const [profileEmployee, setProfileEmployee] = useState<AdminEmployee | null>(null)
  const [profileDepartments, setProfileDepartments] = useState<DepartmentOption[]>([])
  const [isSavingProfile, setIsSavingProfile] = useState(false)
  const [profileError, setProfileError] = useState('')
  const isAdmin = window.location.pathname.startsWith('/admin')

  useEffect(() => {
    if (isAdmin && sessionStorage.getItem('openAdminMenuAfterSignin') === 'true') {
      sessionStorage.removeItem('openAdminMenuAfterSignin')
      sessionStorage.setItem('dashboardMenuOpen', 'true')
      setIsMenuOpen(true)
    }
  }, [isAdmin])

  async function handleSignout() {
    setIsSigningOut(true)
    setError('')
    try {
      await signoutUser()
      window.location.assign('/login')
    } catch (signoutError) {
      setError(signoutError instanceof Error ? signoutError.message : 'We couldn’t sign you out. Please try again.')
      setIsSigningOut(false)
    }
  }

  async function handleSaveProfile() {
    if (!profile) {
      setProfileError('Sign out and sign in again to load your admin profile.')
      return
    }
    setIsSavingProfile(true)
    setProfileError('')
    try {
      await updateUser(profile)
      if (profileEmployee) await updateEmployee(profileEmployee.employee_detail)
      sessionStorage.setItem('currentUser', JSON.stringify(profile))
      setIsEditingProfile(false)
      setIsProfileOpen(false)
    } catch (saveError) {
      setProfileError(saveError instanceof Error ? saveError.message : 'Could not update your profile.')
    } finally {
      setIsSavingProfile(false)
    }
  }

  async function openProfile() {
    setIsProfileOpen(true)
    setIsEditingProfile(false)
    setProfileError('')
    if (!profile?.id) {
      setProfileEmployee(null)
      return
    }

    setIsLoadingProfileDetails(true)
    try {
      const [employees, departmentsResponse] = await Promise.all([getEmployees(), getDepartments()])
      setProfileEmployee(employees.find(({ employee_detail }) => employee_detail.user_id === profile.id) ?? null)
      setProfileDepartments(departmentsResponse.data ?? [])
    } catch (loadError) {
      setProfileError(loadError instanceof Error ? loadError.message : 'Could not load your employee details.')
    } finally {
      setIsLoadingProfileDetails(false)
    }
  }

  function updateProfileField(field: 'name' | 'email', value: string) {
    setProfile((current) => current ? { ...current, [field]: value } : current)
  }

  return (
    <>
      <AppBar position="sticky" color="inherit" elevation={0} sx={{ top: 0, zIndex: (theme) => theme.zIndex.drawer + 1, borderBottom: 1, borderColor: 'primary.main', bgcolor: '#e6f7e9' }}>
        <Toolbar sx={{ minHeight: 76, px: { xs: 2, sm: 3, md: 8 }, gap: 1.5 }}>
          <IconButton aria-label={isMenuOpen ? 'Close dashboard menu' : 'Open dashboard menu'} title="Dashboard menu" color="secondary" onClick={() => setIsMenuOpen((open) => {
            const nextOpen = !open
            sessionStorage.setItem('dashboardMenuOpen', String(nextOpen))
            return nextOpen
          })}>
            <MenuRoundedIcon />
          </IconButton>
          <Drawer anchor="left" open={isMenuOpen} onClose={() => { setIsMenuOpen(false); sessionStorage.setItem('dashboardMenuOpen', 'false') }} PaperProps={{ sx: { top: '76px', height: 'calc(100% - 76px)' } }}>
            <Box sx={{ width: 280, height: '100%', minHeight: '100vh', display: 'flex', flexDirection: 'column' }} role="presentation">
              <Typography variant="overline" color="primary.main" sx={{ px: 2.5, pt: 2, pb: 1, display: 'block', fontWeight: 700 }}>
                {isAdmin ? 'Admin workspace' : 'Employee workspace'}
              </Typography>
              <List sx={{ flex: 1 }}>
                {(isAdmin ? adminLinks : [['Employee dashboard', '/employee-dashboard']]).map(([label, href]) => (
                  <ListItemButton key={href} component="a" href={href} onClick={() => { setIsMenuOpen(false); sessionStorage.setItem('dashboardMenuOpen', 'false') }}>
                    <ListItemText primary={label} />
                  </ListItemButton>
                ))}
                {isAdmin && <ListItemButton disabled><ListItemText primary="Coming soon" /></ListItemButton>}
              </List>
              <Box sx={{ p: 2, borderTop: 1, borderColor: 'divider' }}>
                <Button fullWidth variant="contained" onClick={() => void handleSignout()} disabled={isSigningOut}>
                  {isSigningOut ? 'Signing out…' : 'Sign out'}
                </Button>
              </Box>
            </Box>
          </Drawer>
          <img className="dashboard-logo" src="https://quickinsure.co.in/static/images/quickinsure-logo.svg" alt="QuickInsure" />
          <Box sx={{ flexGrow: 1 }} />
          {isAdmin && <Button color="secondary" startIcon={<AccountCircleRoundedIcon />} onClick={() => { if (isProfileOpen) setIsProfileOpen(false); else void openProfile() }}>Profile</Button>}
          <Drawer
            anchor="right"
            open={isProfileOpen}
            onClose={() => setIsProfileOpen(false)} sx={{ '& .MuiDrawer-paper': { top: '65px', right: 0, left: 'auto', margin: 0, padding: 0, boxSizing: 'border-box', height: '100%', width: { xs: '70vw', sm: 350 } } }} >
            <Box sx={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
              <Box sx={{ px: 3, pt: 4, pb: 2.5, textAlign: 'left', borderBottom: 1, borderColor: 'divider' }}>
                <Typography variant="overline" color="primary.main" sx={{ fontWeight: 700 }}>ADMIN PROFILE</Typography>
                <Typography variant="h6" component="h2" sx={{ fontWeight: 700 }}>Account details</Typography>
              </Box>
              <Box sx={{ flex: 1, overflowY: 'auto', px: 3, py: 2 }}>
                {profileError && <Alert severity="error" sx={{ mb: 2 }}>{profileError}</Alert>}
                {isLoadingProfileDetails ? <Typography color="text.secondary">Loading profile details…</Typography> : <>
                  <Typography variant="subtitle2" sx={{ mt: 1, mb: 1, fontWeight: 700 }}>Admin details</Typography>
                  <TextField fullWidth label="Name" margin="dense" value={profile?.name ?? ''} disabled={!isEditingProfile} onChange={(event) => updateProfileField('name', event.target.value)} />
                  <TextField fullWidth label="Email" type="email" margin="dense" value={profile?.email ?? ''} disabled={!isEditingProfile} onChange={(event) => updateProfileField('email', event.target.value)} />
                  {profileEmployee ? <>
                    <TextField select fullWidth label="Department" margin="dense" value={profileEmployee.employee_detail.department_id} disabled={!isEditingProfile} onChange={(event) => setProfileEmployee((current) => current ? { ...current, employee_detail: { ...current.employee_detail, department_id: event.target.value } } : current)}>
                      {profileDepartments.map((department) => <MenuItem key={department.id} value={department.id}>{department.department_name}</MenuItem>)}
                    </TextField>
                    <TextField fullWidth label="Designation" margin="dense" value={profileEmployee.employee_detail.designation} disabled={!isEditingProfile} onChange={(event) => setProfileEmployee((current) => current ? { ...current, employee_detail: { ...current.employee_detail, designation: event.target.value } } : current)} />
                    <TextField fullWidth label="Base salary" type="number" margin="dense" value={profileEmployee.employee_detail.base_salary} disabled={!isEditingProfile} onChange={(event) => setProfileEmployee((current) => current ? { ...current, employee_detail: { ...current.employee_detail, base_salary: Number(event.target.value) } } : current)} />
                  </> : <Typography color="text.secondary" variant="body2">No employee record is linked to this admin account.</Typography>}
                </>}
              </Box>
              <Box sx={{ display: 'flex', justifyContent: 'flex-end', gap: 1, px: 3, py: 2, borderTop: 1, borderColor: 'divider' }}>
                {isEditingProfile && <Button onClick={() => { setProfile(getStoredProfile()); void openProfile() }} disabled={isSavingProfile}>Cancel</Button>}
                {isEditingProfile
                  ? <Button variant="contained" onClick={() => void handleSaveProfile()} disabled={isSavingProfile || !profile}>{isSavingProfile ? 'Saving…' : 'Save details'}</Button>
                  : <Button variant="contained" onClick={() => setIsEditingProfile(true)} disabled={isLoadingProfileDetails || !profile}>Update</Button>}
              </Box>
            </Box>
          </Drawer>
        </Toolbar>
      </AppBar>
      {error && <Alert severity="error" sx={{ mx: 'auto', mt: 2, width: 'min(1050px, calc(100% - 48px))' }} role="alert">{error}</Alert>}
    </>
  )
}
