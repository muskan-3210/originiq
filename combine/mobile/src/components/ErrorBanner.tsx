export function ErrorBanner({ message }: { message: string }) {
  return (
    <div className="rounded-card border border-danger/30 bg-danger/10 px-4 py-3 text-center text-sm text-ink">
      {message}
    </div>
  )
}
