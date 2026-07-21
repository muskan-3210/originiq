import type { Mutation } from '@/lib/types'
import { monthYear } from '@/lib/format'

export function MutationVersionCard({
  originalText,
  mutation,
}: {
  originalText: string
  mutation: Mutation
}) {
  const similarityPct = Math.round(mutation.similarity_to_origin * 100)

  return (
    <div className="rounded-card border border-line bg-surface p-4">
      <div className="mb-2 flex items-center justify-between">
        <span className="font-display text-sm font-medium text-ink">
          Version {mutation.version} · {mutation.country}
        </span>
        <span className="text-xs text-ink-faint">{monthYear(mutation.date)}</span>
      </div>
      <p className="mb-3 text-sm text-ink-dim">&ldquo;{mutation.text_excerpt}&rdquo;</p>
      <div className="flex items-center gap-2">
        <div className="h-1.5 flex-1 overflow-hidden rounded-pill bg-surface-raised">
          <div className="h-full rounded-pill bg-amber" style={{ width: `${similarityPct}%` }} />
        </div>
        <span className="text-xs text-ink-faint">{similarityPct}% similar to original</span>
      </div>
      {originalText ? (
        <p className="mt-2 truncate text-xs text-ink-faint" title={originalText}>
          Original: &ldquo;{originalText}&rdquo;
        </p>
      ) : null}
    </div>
  )
}
