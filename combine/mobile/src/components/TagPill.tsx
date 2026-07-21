function toLabel(tag: string): string {
  return tag.replace(/-/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase())
}

export function TagPill({ label }: { label: string }) {
  return (
    <span className="rounded-pill border border-line bg-surface-raised px-3 py-1 text-xs text-ink-dim">
      {toLabel(label)}
    </span>
  )
}
