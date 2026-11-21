import { useEffect, useState } from 'react'
import { Alert, Box, Button, Card, CardActions, CardContent, Stack, Typography } from '@mui/material'
import EventNoteRoundedIcon from '@mui/icons-material/EventNoteRounded'
import ScheduleRoundedIcon from '@mui/icons-material/ScheduleRounded'
import PersonSearchRoundedIcon from '@mui/icons-material/PersonSearchRounded'
import AutoAwesomeRoundedIcon from '@mui/icons-material/AutoAwesomeRounded'
import DashboardHeader from '../dashboard/DashboardHeader'
import { getAttendanceExceptions, getUsers } from './adminApi'

type Counts = { leaves: number; regularizations: number; users: number }
const cards = [
  { title: 'Pending Leaves', description: 'Leave requests are waiting for your review.', action: 'Review Leaves', href: '/admin/pending-leaves', count: 'leaves' as const, Icon: EventNoteRoundedIcon },
  { title: 'Pending Regularizations', description: 'Attendance corrections are waiting for review.', action: 'Review Regularizations', href: '/admin/pending-regularizations', count: 'regularizations' as const, Icon: ScheduleRoundedIcon },
  { title: 'New User Verification', description: 'New users need their details reviewed.', action: 'Review Users', href: '/admin/users', count: 'users' as const, Icon: PersonSearchRoundedIcon },
  { title: 'Coming Soon', description: 'More features coming soon.', Icon: AutoAwesomeRoundedIcon },
]

export default function AdminDashboard() {
  const [counts, setCounts] = useState<Counts | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  useEffect(() => {
    let active = true
    Promise.all([getAttendanceExceptions(), getUsers()])
      .then(([exceptionResponse, userResponse]) => {
        if (!active) return
        const exceptions = exceptionResponse.data ?? []
        setCounts({
          leaves: exceptions.filter(({ attendance_exception }) => attendance_exception.request_type === 'leave' && ['pending', 'partially_approved'].includes(attendance_exception.status)).length,
          regularizations: exceptions.filter(({ attendance_exception }) => attendance_exception.request_type === 'regularization' && attendance_exception.status === 'pending').length,
          users: (userResponse.data ?? []).filter((user) => user.phase === 'new').length,
        })
      })
      .catch((fetchError) => { if (active) setError(fetchError instanceof Error ? fetchError.message : 'Could not load dashboard counts.') })
      .finally(() => { if (active) setLoading(false) })
    return () => { active = false }
  }, [])

  return (
    <Box sx={{ minHeight: '100vh', bgcolor: 'background.default' }}>
      <DashboardHeader />
      <Box component="main" sx={{ width: 'min(1080px, calc(100% - 48px))', mx: 'auto', py: { xs: 4, md: 8 } }}>
        <Stack spacing={1} sx={{ mb: 4 }}>
          <Typography variant="overline" color="primary.main" sx={{ fontWeight: 700, letterSpacing: 1.6 }}>Admin workspace</Typography>
          <Typography variant="h3" component="h1" sx={{ fontWeight: 700, letterSpacing: '-1.5px', fontSize: { xs: 32, md: 40 } }}>Admin dashboard</Typography>
          <Typography color="text.secondary">Review requests and keep your team moving.</Typography>
        </Stack>
        {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}
        <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', sm: 'repeat(2, minmax(0, 1fr))' }, gap: 2.5, alignItems: 'stretch' }}>
          {cards.map(({ title, description, action, href, count, Icon }) => (
            <Card key={title} variant="outlined" sx={{ minHeight: 242, display: 'flex', flexDirection: 'column', borderColor: 'primary.main', borderRadius: 3, transition: 'transform .2s ease, box-shadow .2s ease', '&:hover': { transform: 'translateY(-3px)', boxShadow: 4 } }}>
              <CardContent sx={{ flexGrow: 1, p: 3 }}>
                <Stack direction="row" sx={{ mb: 2, justifyContent: 'space-between', alignItems: 'flex-start' }}>
                  <Box sx={{ width: 46, height: 46, display: 'grid', placeItems: 'center', borderRadius: 2, color: 'primary.main', bgcolor: 'primary.light' }}>
                    <Icon />
                  </Box>
                  {count && <Typography variant="h4" component="p" color="secondary.main" sx={{ fontWeight: 700 }} aria-label={loading ? 'Loading count' : `${counts?.[count] ?? 0} pending`}>{loading ? '—' : counts?.[count] ?? '—'}</Typography>}
                </Stack>
                <Typography variant="h6" component="h2" sx={{ fontWeight: 700, mb: .75 }}>{title}</Typography>
                <Typography variant="body2" color="text.secondary">{description}</Typography>
              </CardContent>
              <CardActions sx={{ px: 3, pb: 2.5, pt: 0 }}>
                {action && href
                  ? <Button href={href} variant="contained" endIcon={<span aria-hidden="true">→</span>}>{action}</Button>
                  : <Typography variant="body2" color="text.secondary">More features coming soon</Typography>}
              </CardActions>
            </Card>
          ))}
        </Box>
      </Box>
    </Box>
  )
}
