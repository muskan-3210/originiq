import { useState } from 'react'
import { NavLink } from 'react-router-dom'

interface NavItem {
  to: string
  label: string
  end?: boolean
}

const LINKS: NavItem[] = [
  { to: '/', label: 'Home', end: true },
  { to: '/map', label: 'Spread map' },
  { to: '/leaderboard', label: 'Leaderboard' },
  { to: '/api', label: 'API docs' },
]

export function Nav() {
  const [open, setOpen] = useState(false)

  return (
    <header className="sticky top-0 z-20 border-b border-hairline border-borderDefault bg-base/95 backdrop-blur">
      <nav className="mx-auto flex max-w-6xl items-center justify-between px-5 py-4" aria-label="Primary">
        <NavLink
          to="/"
          className="flex items-center gap-2 font-display text-lg font-medium text-textPrimary"
          onClick={() => setOpen(false)}
        >
          <span aria-hidden="true" className="inline-block h-2 w-2 rounded-pill bg-gold" />
          ORACLE
        </NavLink>

        <button
          type="button"
          className="rounded-button border border-hairline border-borderDefault p-2 text-textSecondary sm:hidden"
          aria-expanded={open}
          aria-controls="primary-nav-links"
          aria-label={open ? 'Close menu' : 'Open menu'}
          onClick={() => setOpen((value) => !value)}
        >
          <MenuIcon open={open} />
        </button>

        <ul
          id="primary-nav-links"
          className={`${
            open ? 'flex' : 'hidden'
          } absolute inset-x-0 top-[65px] flex-col gap-1 border-b border-hairline border-borderDefault bg-base px-5 py-4 sm:static sm:flex sm:flex-row sm:items-center sm:gap-6 sm:border-none sm:bg-transparent sm:p-0`}
        >
          {LINKS.map((link) => (
            <li key={link.to}>
              <NavLink
                to={link.to}
                end={link.end}
                onClick={() => setOpen(false)}
                className={({ isActive }) =>
                  `block rounded-button px-3 py-2 text-sm transition-colors sm:px-0 sm:py-0 ${
                    isActive ? 'text-gold' : 'text-textSecondary hover:text-textPrimary'
                  }`
                }
              >
                {link.label}
              </NavLink>
            </li>
          ))}
        </ul>
      </nav>
    </header>
  )
}

function MenuIcon({ open }: { open: boolean }) {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" aria-hidden="true">
      {open ? (
        <path d="M6 6l12 12M18 6L6 18" strokeLinecap="round" />
      ) : (
        <path d="M4 7h16M4 12h16M4 17h16" strokeLinecap="round" />
      )}
    </svg>
  )
}
