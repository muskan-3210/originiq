import type { Verdict } from '@/lib/types'

const VERDICT_META: Record<Verdict, { label: string; className: string }> = {
  false: { label: 'False', className: 'bg-danger/15 text-danger' },
  misleading: { label: 'Misleading', className: 'bg-amber/15 text-amber' },
  true: { label: 'True', className: 'bg-teal/15 text-teal' },
  unverified: { label: 'Unverified', className: 'bg-surface-raised text-ink-faint' },
}

export function VerdictBadge({ verdict }: { verdict: Verdict }) {
  const meta = VERDICT_META[verdict]
  return (
    <span className={`inline-block rounded-pill px-3 py-1 text-xs font-medium ${meta.className}`}>
      {meta.label}
    </span>
  )
}
