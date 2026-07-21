'use client'

import { useRouter } from 'next/navigation'
import { useEffect } from 'react'

import { useFlow } from '@/context/FlowContext'
import { COPY, TIMING } from '@/lib/constants'
import { hopsNote } from '@/lib/format'
import { OriginCard } from '@/components/OriginCard'
import { TagPill } from '@/components/TagPill'
import { SecondaryButton } from '@/components/SecondaryButton'

export default function OriginPage() {
  const router = useRouter()
  const { analysis } = useFlow()

  useEffect(() => {
    if (!analysis) return
    const hasOrigin = analysis.origin !== null
    const dwell = hasOrigin ? TIMING.storyDwellDuration : TIMING.storyDwellDurationShort
    const timer = setTimeout(() => {
      router.push(hasOrigin ? '/mutation' : '/')
    }, dwell)
    return () => clearTimeout(timer)
  }, [analysis, router])

  if (!analysis) {
    return (
      <main className="flex flex-1 flex-col items-center justify-center gap-4 px-5 py-10 text-center">
        <h2 className="text-xl text-ink">Nothing to trace yet</h2>
        <p className="text-sm text-ink-dim">Paste something on Home to start a new trace.</p>
        <SecondaryButton onClick={() => router.push('/')}>Back to home</SecondaryButton>
      </main>
    )
  }

  if (!analysis.origin) {
    return (
      <main className="flex flex-1 flex-col items-center justify-center gap-3 px-5 py-10 text-center">
        <CompassIcon />
        <h1 className="text-2xl text-ink">{COPY.newTerritoryHeadline}</h1>
        <p className="text-sm text-ink-dim">{COPY.newTerritoryBody}</p>
      </main>
    )
  }

  const { origin } = analysis

  return (
    <main className="flex flex-1 flex-col gap-6 px-5 py-10">
      <h1 className="text-2xl text-ink">Origin</h1>
      <OriginCard origin={origin} />
      {origin.tags.length > 0 ? (
        <div className="flex flex-wrap gap-2">
          {origin.tags.map((tag) => (
            <TagPill key={tag} label={tag} />
          ))}
        </div>
      ) : null}
      <p className="text-sm text-ink-dim">{hopsNote(origin.hops_traced)}</p>
    </main>
  )
}

function CompassIcon() {
  return (
    <svg width="40" height="40" viewBox="0 0 24 24" fill="none" aria-hidden="true" className="text-ink-faint">
      <circle cx="12" cy="12" r="9" stroke="currentColor" strokeWidth="1.6" />
      <path d="m15 9-4.5 1.5L9 15l4.5-1.5L15 9Z" stroke="currentColor" strokeWidth="1.6" strokeLinejoin="round" />
    </svg>
  )
}
