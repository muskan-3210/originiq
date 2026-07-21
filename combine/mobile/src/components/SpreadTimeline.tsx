import type { Mutation, Origin } from '@/lib/types'
import { monthYear, platformLabel } from '@/lib/format'

interface Node {
  label: string
  country: string
  date: string
}

export function SpreadTimeline({ origin, mutations }: { origin: Origin; mutations: Mutation[] }) {
  const nodes: Node[] = [
    { label: platformLabel(origin.platform), country: origin.country, date: origin.date },
    ...mutations.map((m) => ({ label: `Version ${m.version}`, country: m.country, date: m.date })),
  ]

  return (
    <ol className="relative border-l border-line pl-6">
      {nodes.map((node, i) => (
        <li key={i} className="mb-6 last:mb-0">
          <span
            className={`absolute -left-[5px] mt-1.5 h-2.5 w-2.5 rounded-full ${
              i === 0 ? 'bg-danger' : 'bg-gold'
            }`}
          />
          <p className="font-display text-sm font-medium text-ink">{node.label}</p>
          <p className="text-xs text-ink-dim">
            {node.country} · {monthYear(node.date)}
          </p>
        </li>
      ))}
    </ol>
  )
}
