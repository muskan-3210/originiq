import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'

import App from './App'
import './index.css'

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
      retry: 1,
      // This is a public dashboard, not an offline-first app: we'd rather a query settle
      // to a definite success/error quickly (so the UI can show a clear message) than sit
      // "paused" waiting for the browser to report connectivity restored, which can also
      // happen to get stuck in edge cases (proxies, privacy extensions, flaky detection).
      networkMode: 'always',
    },
  },
})

const rootElement = document.getElementById('root')
if (!rootElement) {
  throw new Error('Root element with id "root" was not found in index.html.')
}

createRoot(rootElement).render(
  <StrictMode>
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <App />
      </BrowserRouter>
    </QueryClientProvider>
  </StrictMode>,
)
