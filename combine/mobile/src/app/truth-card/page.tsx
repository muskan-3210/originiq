'use client'

import { useRouter } from 'next/navigation'
import { useState } from 'react'

import { useFlow } from '@/context/FlowContext'
import { COPY } from '@/lib/constants'
import { VerdictBadge } from '@/components/VerdictBadge'
import { PrimaryButton } from '@/components/PrimaryButton'
import { SecondaryButton } from '@/components/SecondaryButton'
import { ErrorBanner } from '@/components/ErrorBanner'

export default function TruthCardPage() {
  const router = useRouter()
  const { analysis, setAnalysis, setScanRequest } = useFlow()
  const [shareError, setShareError] = useState<string | null>(null)
  const [shared, setShared] = useState(false)

  function finish() {
    setAnalysis(null)
    setScanRequest(null)
    router.push('/')
  }

  async function handleShare() {
    setShareError(null)
    const text = `${COPY.truthCardTagline} Traced with ORACLE.`
    try {
      if (navigator.share) {
        await navigator.share({ text })
      } else {
        await navigator.clipboard.writeText(text)
      }
      setShared(true)
    } catch {
      setShareError("The truth card couldn't be shared — try again.")
    }
  }

  if (!analysis) {
    return (
      <main className="flex flex-1 flex-col items-center justify-center gap-4 px-5 py-10 text-center">
        <h2 className="text-xl text-ink">Nothing to share yet</h2>
        <p className="text-sm text-ink-dim">Paste something on Home to start a new trace.</p>
        <SecondaryButton onClick={() => router.push('/')}>Back to home</SecondaryButton>
      </main>
    )
  }

  return (
    <main className="flex flex-1 flex-col gap-6 px-5 py-10">
      <div className="rounded-card border border-line bg-surface p-6">
        <VerdictBadge verdict={analysis.verdict} />
        {analysis.claimText ? (
          <p className="mt-4 text-sm text-ink">&ldquo;{analysis.claimText}&rdquo;</p>
        ) : null}
        <p className="mt-6 font-display text-lg text-gold">{COPY.truthCardTagline}</p>
      </div>

      {shareError ? <ErrorBanner message={shareError} /> : null}
      {shared ? <p className="text-center text-sm text-ink-dim">Shared</p> : null}

      <PrimaryButton onClick={handleShare}>Save &amp; share</PrimaryButton>
      <SecondaryButton onClick={finish}>Done</SecondaryButton>
      <button
        type="button"
        onClick={finish}
        className="text-center text-sm text-ink-faint underline underline-offset-2"
      >
        {COPY.skipSharing}
      </button>
    </main>
  )
}
