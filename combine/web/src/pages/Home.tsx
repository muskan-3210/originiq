import { Link } from 'react-router-dom'

import { useGlobalStats } from '../hooks/useGlobalStats'
import { StatCounter } from '../components/StatCounter'
import { DownloadCta } from '../components/DownloadCta'

const PITCH =
  'While everyone fights fake news today, ORACLE goes back in time to show you where it was born, how it mutated, and the real damage it caused.'

const STEPS = [
  {
    title: 'Paste, share, or upload',
    body: 'Drop in a forwarded message, a screenshot, or a link — no forms, no quiz, no judgment call to make.',
  },
  {
    title: 'ORACLE traces the story',
    body: 'It finds where the claim was born, how it mutated as it crossed platforms and borders, and what it did.',
  },
  {
    title: 'See the real damage',
    body: 'Documented, sourced impact — not a vague "this is false" — makes the harm concrete enough to stop sharing.',
  },
]

export function Home() {
  const { data, isError } = useGlobalStats()

  const stats = data ?? { chains_broken_today: 0, chains_broken_total: 0, countries_covered: 0 }
  // Covers every "we don't have real numbers yet" case in one condition: the initial
  // fetch, a settled error, and a fetch paused by network-mode detection (e.g. a
  // transient offline blip) — react-query can sit in that last state for a while without
  // flipping to isError, so checking `!data` directly is the robust signal to fall back on.
  const showConnectingNote = !data

  return (
    <div>
      <section className="mx-auto max-w-4xl px-5 pb-14 pt-20 text-center sm:pt-28">
        <p className="font-display text-sm font-medium text-gold">The fake news time machine</p>
        <h1 className="mt-4 font-display text-3xl font-medium leading-tight text-textPrimary sm:text-4xl md:text-5xl">
          {PITCH}
        </h1>
        <div className="mt-8 flex flex-wrap items-center justify-center gap-3">
          <a
            href="#download"
            className="rounded-button bg-gold px-5 py-3 text-sm font-medium text-base transition-opacity hover:opacity-90"
          >
            Get the app
          </a>
          <Link
            to="/map"
            className="rounded-button border border-hairline border-borderDefault px-5 py-3 text-sm text-textSecondary transition-colors hover:border-borderStrong hover:text-textPrimary"
          >
            Explore the spread map
          </Link>
        </div>
      </section>

      <section className="border-y border-hairline border-borderDefault bg-surface/40">
        <div className="mx-auto max-w-5xl px-5 py-14">
          {showConnectingNote ? (
            <p className="mb-8 text-center text-xs text-textMuted">
              {isError ? 'Could not reach the backend yet — showing placeholder numbers.' : 'Connecting to live data…'}
            </p>
          ) : null}
          <div className="grid grid-cols-1 gap-10 sm:grid-cols-3">
            <StatCounter value={stats.chains_broken_today} label="Chains broken today" />
            <StatCounter value={stats.chains_broken_total} label="Chains broken all-time" />
            <StatCounter value={stats.countries_covered} label="Countries covered" />
          </div>
        </div>
      </section>

      <section className="mx-auto max-w-5xl px-5 py-16">
        <h2 className="text-center font-display text-2xl font-medium text-textPrimary">How it works</h2>
        <div className="mt-10 grid grid-cols-1 gap-6 sm:grid-cols-3">
          {STEPS.map((step, index) => (
            <div
              key={step.title}
              className="rounded-card border border-hairline border-borderDefault bg-surface p-6"
            >
              <span className="font-display text-sm font-medium text-gold">{String(index + 1).padStart(2, '0')}</span>
              <p className="mt-3 font-display text-base font-medium text-textPrimary">{step.title}</p>
              <p className="mt-2 text-sm text-textSecondary">{step.body}</p>
            </div>
          ))}
        </div>
      </section>

      <section id="download" className="mx-auto max-w-4xl px-5 pb-20">
        <DownloadCta />
      </section>
    </div>
  )
}
