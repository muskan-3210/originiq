import { lazy, Suspense } from 'react'
import { Route, Routes } from 'react-router-dom'

import { Layout } from './components/Layout'
import { Loading } from './components/Loading'
import { Home } from './pages/Home'
import { Leaderboard } from './pages/Leaderboard'
import { ApiDocs } from './pages/ApiDocs'

// Mapbox GL is a large, map-only dependency — load it lazily so visitors who never
// open the spread map don't pay for it on their initial page load.
const SpreadMap = lazy(() => import('./pages/SpreadMap').then((module) => ({ default: module.SpreadMap })))

function NotFound() {
  return (
    <div className="mx-auto max-w-2xl px-5 py-24 text-center">
      <p className="font-display text-2xl font-medium text-textPrimary">Page not found</p>
      <p className="mt-2 text-textSecondary">This page doesn&rsquo;t exist. Try one of the links above.</p>
    </div>
  )
}

export default function App() {
  return (
    <Routes>
      <Route element={<Layout />}>
        <Route path="/" element={<Home />} />
        <Route
          path="/map"
          element={
            <Suspense
              fallback={
                <div className="flex justify-center py-24">
                  <Loading label="Loading the spread map…" />
                </div>
              }
            >
              <SpreadMap />
            </Suspense>
          }
        />
        <Route path="/leaderboard" element={<Leaderboard />} />
        <Route path="/api" element={<ApiDocs />} />
        <Route path="*" element={<NotFound />} />
      </Route>
    </Routes>
  )
}
