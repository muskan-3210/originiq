import type { ReactNode } from 'react'

interface EmptyStateProps {
  title: string
  description?: string
  action?: ReactNode
  className?: string
}

/** An invitation, not an apology — matches the product's empty-state copy rules. */
export function EmptyState({ title, description, action, className = '' }: EmptyStateProps) {
  return (
    <div className={`rounded-card border border-hairline border-borderDefault bg-surface px-6 py-10 text-center ${className}`}>
      <p className="font-display text-base font-medium text-textPrimary">{title}</p>
      {description ? <p className="mx-auto mt-2 max-w-md text-sm text-textSecondary">{description}</p> : null}
      {action ? <div className="mt-4 flex justify-center">{action}</div> : null}
    </div>
  )
}
