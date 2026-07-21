import type { Origin } from '@/lib/types'
import { monthYear, platformLabel } from '@/lib/format'

export function OriginCard({ origin }: { origin: Origin }) {
  return (
    <div className="flex items-center gap-4 rounded-card border border-danger/30 bg-danger/10 p-4">
      <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-danger/20 text-danger">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" aria-hidden="true">
          <path
            d="M12 21s7-6.5 7-11.5A7 7 0 0 0 5 9.5C5 14.5 12 21 12 21Z"
            stroke="currentColor"
            strokeWidth="1.8"
            strokeLinejoin="round"
          />
          <circle cx="12" cy="9.5" r="2.25" stroke="currentColor" strokeWidth="1.8" />
        </svg>
      </div>
      <div>
        <p className="font-display text-base font-medium text-ink">Born on {platformLabel(origin.platform)}</p>
        <p className="text-sm text-ink-dim">
          {origin.country}, {monthYear(origin.date)}
        </p>
      </div>
    </div>
  )
}
