interface LoadingProps {
  label?: string
  className?: string
}

/** A small inline spinner + label. Used for any in-flight network state. */
export function Loading({ label = 'Loading…', className = '' }: LoadingProps) {
  return (
    <div role="status" className={`flex items-center gap-3 ${className}`}>
      <span
        aria-hidden="true"
        className="h-4 w-4 shrink-0 animate-spin rounded-pill border-2 border-borderStrong border-t-gold"
      />
      <span className="text-sm text-textSecondary">{label}</span>
    </div>
  )
}
