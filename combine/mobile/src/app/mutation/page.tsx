'use client'

import { useRouter } from 'next/navigation'
import { useEffect } from 'react'

import { useFlow } from '@/context/FlowContext'
import { COPY, TIMING } from '@/lib/constants'
import { SpreadTimeline } from '@/components/SpreadTimeline'
import { MutationVersionCard } from '@/components/MutationVersionCard'
import { SecondaryButton } from '@/components/SecondaryButton'

export default function MutationPage() {
  const router = useRouter()
  const { analysis } = useFlow()
  const hasMutations = (analysis?.mutations.length ?? 0) > 0

  useEffect(() => {
    if (!analysis || !analysis.origin) return
    const dwell = hasMutations ? TIMING.storyDwellDuration : TIMING.storyDwellDurationShort
    const timer = setTimeout(() => router.push('/damage'), dwell)
    return () => clearTimeout(timer)
  }, [analysis, hasMutations, router])

  if (!analysis || !analysis.origin) {
    return (
      <main className="flex flex-1 flex-col items-center justify-center gap-4 px-5 py-10 text-center">
        <h2 className="text-xl text-ink">Nothing to trace yet</h2>
        <p className="text-sm text-ink-dim">Paste something on Home to start a new trace.</p>
        <SecondaryButton onClick={() => router.push('/')}>Back to home</SecondaryButton>
      </main>
    )
  }

  const { origin, mutations } = analysis
  const countryCount = 1 + new Set(mutations.map((m) => m.country)).size

  return (
    <main className="flex flex-1 flex-col gap-6 px-5 py-10">
      <h1 className="text-2xl text-ink">
        Spread across {countryCount} {countryCount === 1 ? 'country' : 'countries'}
      </h1>
      <SpreadTimeline origin={origin} mutations={mutations} />
      {mutations.length === 0 ? (
        <p className="text-sm text-ink-dim">{COPY.noFurtherSpread}</p>
      ) : (
        <div className="flex flex-col gap-3">
          {mutations.map((mutation) => (
            <MutationVersionCard
              key={mutation.version}
              originalText={analysis.claimText ?? ''}
              mutation={mutation}
            />
          ))}
        </div>
      )}
    </main>
  )
}
