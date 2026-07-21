import type { DamageStat } from '@/lib/types'

function formatValue(value: number): string {
  if (value >= 1000) return `${(value / 1000).toFixed(value % 1000 === 0 ? 0 : 1)}k`
  return `${value}`
}

export function StatCounterCard({ stat }: { stat: DamageStat }) {
  return (
    <div className="flex flex-col justify-between rounded-card border border-line bg-surface p-4">
      <div>
        <p className="font-display text-2xl font-medium text-amber">{formatValue(stat.value)}</p>
        <p className="mt-1 text-sm font-medium text-ink">{stat.label}</p>
        <p className="mt-1 text-xs text-ink-dim">{stat.description}</p>
      </div>
      {stat.source_name ? (
        <a
          href={stat.source_url}
          target="_blank"
          rel="noreferrer"
          className="mt-3 truncate text-xs text-ink-faint underline decoration-line-strong underline-offset-2 hover:text-ink-dim"
        >
          {stat.source_name}
        </a>
      ) : null}
    </div>
  )
}
