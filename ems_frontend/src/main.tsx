import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { CssBaseline, ThemeProvider, createTheme } from '@mui/material'
import './index.css'
import App from './App.tsx'

const theme = createTheme({
  palette: {
    primary: { main: '#2ACB55' },
    secondary: { main: '#205d32' },
    background: { default: '#ffffff', paper: '#ffffff' },
    text: { primary: '#205d32', secondary: '#5d7163' },
  },
  shape: { borderRadius: 10 },
  typography: { fontFamily: "'DM Sans', sans-serif", button: { textTransform: 'none', fontWeight: 700 } },
})

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <App />
    </ThemeProvider>
  </StrictMode>,
)
