interface ErrorStateProps {
  message: string
  onRetry?: () => void
  className?: string
}

/** Inline error banner: states what happened and what to do next, never a raw stack trace. */
export function ErrorState({ message, onRetry, className = '' }: ErrorStateProps) {
  return (
    <div
      role="alert"
      className={`rounded-card border border-hairline border-danger/40 bg-danger/10 px-6 py-6 text-center ${className}`}
    >
      <p className="text-sm text-textPrimary">{message}</p>
      {onRetry ? (
        <button
          type="button"
          onClick={onRetry}
          className="mt-4 rounded-button border border-hairline border-borderStrong px-4 py-2 text-sm text-textPrimary transition-colors hover:border-gold hover:text-gold"
        >
          Try again
        </button>
      ) : null}
    </div>
  )
}
