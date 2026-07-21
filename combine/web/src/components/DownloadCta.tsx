interface DownloadCtaProps {
  className?: string
}

/**
 * CTA to "download the app". The mobile app is still in hackathon pilot testing, so real
 * store links would 404 or point to the wrong app — instead of a dead or misleading link,
 * this renders honest "coming soon" badges plus one real, working action (email the team).
 */
export function DownloadCta({ className = '' }: DownloadCtaProps) {
  return (
    <div className={`rounded-card border border-hairline border-borderDefault bg-surfaceRaised p-8 text-center ${className}`}>
      <h2 className="font-display text-xl font-medium text-textPrimary">Take ORACLE with you</h2>
      <p className="mx-auto mt-2 max-w-md text-sm text-textSecondary">
        The mobile app traces any suspicious message back to its origin in seconds — paste, share, or
        upload, no quiz required.
      </p>

      <div className="mt-6 flex flex-wrap items-center justify-center gap-3">
        <span
          aria-disabled="true"
          title="Coming soon"
          className="inline-flex cursor-not-allowed items-center gap-2 rounded-button border border-hairline border-borderStrong bg-surface px-5 py-3 text-sm text-textSecondary opacity-70"
        >
          <AppleMark />
          App Store — coming soon
        </span>
        <span
          aria-disabled="true"
          title="Coming soon"
          className="inline-flex cursor-not-allowed items-center gap-2 rounded-button border border-hairline border-borderStrong bg-surface px-5 py-3 text-sm text-textSecondary opacity-70"
        >
          <PlayMark />
          Google Play — coming soon
        </span>
      </div>

      <p className="mt-4 text-xs text-textMuted">
        In final hackathon testing — store links go live at launch. Want early access?{' '}
        <a
          href="mailto:hello@oracle-app.example?subject=ORACLE%20early%20access"
          className="text-gold underline-offset-2 hover:underline"
        >
          Ask to join the pilot
        </a>
        .
      </p>
    </div>
  )
}

function AppleMark() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
      <path d="M16.365 1.43c0 1.14-.462 2.246-1.164 3.038-.78.884-2.052 1.57-3.12 1.484-.132-1.1.42-2.25 1.128-3.02.792-.87 2.19-1.53 3.156-1.502zM20.64 17.36c-.492 1.14-.726 1.65-1.356 2.658-.876 1.404-2.112 3.15-3.648 3.162-1.368.012-1.716-.888-3.564-.876-1.848.012-2.232.888-3.6.876-1.536-.012-2.706-1.596-3.582-3-2.454-3.918-2.712-8.514-1.2-10.968.99-1.62 2.7-2.646 4.416-2.646 1.848 0 3.012.996 4.548.996 1.5 0 2.4-1.002 4.548-1.002 1.5 0 3.084.816 4.212 2.226-3.708 2.028-3.108 7.32.226 8.574z" />
    </svg>
  )
}

function PlayMark() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
      <path d="M3 3.6v16.8c0 .3.156.564.396.708l9.084-9.108L3.396 2.892A.84.84 0 003 3.6zM14.94 12l2.508-2.508 3.108 1.776c.66.378.66 1.284 0 1.662l-3.108 1.776L14.94 12zM13.836 13.104L4.62 22.32c.126.036.264.048.396.024a.84.84 0 00.372-.12l10.578-6.048-2.13-2.13v.06zM13.836 10.896l2.13-2.13L5.388 2.718A.84.84 0 004.62 2.7l9.216 8.196z" />
    </svg>
  )
}
