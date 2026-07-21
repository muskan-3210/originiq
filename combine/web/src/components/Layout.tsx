import { Outlet } from 'react-router-dom'

import { Nav } from './Nav'
import { Footer } from './Footer'

/** Shared dark shell (nav + footer) around every routed page. */
export function Layout() {
  return (
    <div className="flex min-h-screen flex-col bg-base text-textPrimary">
      <Nav />
      <main className="flex-1">
        <Outlet />
      </main>
      <Footer />
    </div>
  )
}
