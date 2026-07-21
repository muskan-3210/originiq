import type { Verdict } from '../lib/types'

const VERDICT_LABEL: Record<Verdict, string> = {
  false: 'False',
  misleading: 'Misleading',
  true: 'True',
  unverified: 'Unverified',
}

const VERDICT_STYLE: Record<Verdict, string> = {
  false: 'border-danger/40 bg-danger/15 text-danger',
  misleading: 'border-amber/40 bg-amber/15 text-amber',
  true: 'border-teal/40 bg-teal/15 text-teal',
  unverified: 'border-borderDefault bg-surfaceRaised text-textSecondary',
}

interface VerdictBadgeProps {
  verdict: Verdict
  className?: string
}

/** Small colored pill for a claim's verdict — always paired with its text label. */
export function VerdictBadge({ verdict, className = '' }: VerdictBadgeProps) {
  return (
    <span
      role="status"
      aria-label={`Verdict: ${VERDICT_LABEL[verdict]}`}
      className={`inline-flex items-center rounded-pill border border-hairline px-3 py-1 font-display text-xs font-medium ${VERDICT_STYLE[verdict]} ${className}`}
    >
      {VERDICT_LABEL[verdict]}
    </span>
  )
}
