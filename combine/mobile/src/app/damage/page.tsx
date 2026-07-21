'use client'

import { useRouter } from 'next/navigation'
import { useEffect } from 'react'

import { useFlow } from '@/context/FlowContext'
import { COPY, TIMING } from '@/lib/constants'
import { StatCounterCard } from '@/components/StatCounterCard'
import { SecondaryButton } from '@/components/SecondaryButton'

export default function DamagePage() {
  const router = useRouter()
  const { analysis } = useFlow()
  const hasDamage = (analysis?.damage.length ?? 0) > 0

  useEffect(() => {
    if (!analysis) return
    const dwell = hasDamage ? TIMING.storyDwellDuration : TIMING.storyDwellDurationShort
    const timer = setTimeout(() => router.push('/truth-card'), dwell)
    return () => clearTimeout(timer)
  }, [analysis, hasDamage, router])

  if (!analysis) {
    return (
      <main className="flex flex-1 flex-col items-center justify-center gap-4 px-5 py-10 text-center">
        <h2 className="text-xl text-ink">Nothing to trace yet</h2>
        <p className="text-sm text-ink-dim">Paste something on Home to start a new trace.</p>
        <SecondaryButton onClick={() => router.push('/')}>Back to home</SecondaryButton>
      </main>
    )
  }

  const stats = analysis.damage.slice(0, 4)

  return (
    <main className="flex flex-1 flex-col gap-6 px-5 py-10">
      <h1 className="text-2xl text-ink">Damage report</h1>
      {stats.length === 0 ? (
        <p className="flex flex-1 items-center justify-center text-center text-sm text-ink-dim">
          {COPY.noDamageRecorded}
        </p>
      ) : (
        <div className="grid grid-cols-2 gap-3">
          {stats.map((stat, i) => (
            <StatCounterCard key={i} stat={stat} />
          ))}
        </div>
      )}
    </main>
  )
}
