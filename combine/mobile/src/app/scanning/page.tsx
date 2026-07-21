'use client'

import { useRouter } from 'next/navigation'
import { useEffect, useState } from 'react'

import { useFlow } from '@/context/FlowContext'
import { analyze } from '@/lib/api'
import { COPY, TIMING } from '@/lib/constants'
import { ErrorBanner } from '@/components/ErrorBanner'
import { SecondaryButton } from '@/components/SecondaryButton'

const STAGES = ['Checking language', 'Matching similar claims', 'Cross-referencing sources']

export default function ScanningPage() {
  const router = useRouter()
  const { scanRequest, setAnalysis } = useFlow()
  const [completedCount, setCompletedCount] = useState(0)
  const [hasTimedOut, setHasTimedOut] = useState(false)
  const [retryKey, setRetryKey] = useState(0)

  useEffect(() => {
    if (!scanRequest) {
      router.replace('/')
      return
    }

    let cancelled = false
    const timers: ReturnType<typeof setTimeout>[] = []

    function scheduleStage(index: number) {
      timers.push(
        setTimeout(() => {
          if (cancelled) return
          setCompletedCount(index + 1)
          if (index + 1 >= STAGES.length) {
            void runScan()
          } else {
            scheduleStage(index + 1)
          }
        }, TIMING.scanStageDuration),
      )
    }

    async function runScan() {
      try {
        const result = await analyze(scanRequest!.kind, scanRequest!.value)
        if (cancelled) return
        setAnalysis({ ...result, claimText: scanRequest!.value })
        router.push('/origin')
      } catch {
        if (cancelled) return
        setHasTimedOut(true)
      }
    }

    scheduleStage(0)
    return () => {
      cancelled = true
      timers.forEach(clearTimeout)
    }
  }, [scanRequest, retryKey, router, setAnalysis])

  function retry() {
    setHasTimedOut(false)
    setCompletedCount(0)
    setRetryKey((k) => k + 1)
  }

  const progress = STAGES.length === 0 ? 0 : completedCount / STAGES.length

  return (
    <main className="flex flex-1 flex-col items-center justify-center gap-8 px-5 py-10">
      {hasTimedOut ? (
        <div className="flex w-full flex-col items-center gap-4">
          <ErrorBanner message={COPY.scanTakingLong} />
          <SecondaryButton onClick={retry}>Retry</SecondaryButton>
        </div>
      ) : (
        <>
          <div className="h-14 w-14 animate-spin rounded-full border-2 border-line-strong border-t-gold" />
          <ul className="w-full space-y-2">
            {STAGES.map((stage, i) => (
              <li
                key={stage}
                className={`text-sm transition-colors ${
                  i < completedCount ? 'text-ink' : 'text-ink-faint'
                }`}
              >
                {i < completedCount ? '✓ ' : ''}
                {stage}
              </li>
            ))}
          </ul>
          <div className="h-1.5 w-full overflow-hidden rounded-pill bg-surface-raised">
            <div
              className="h-full rounded-pill bg-gold transition-all duration-300"
              style={{ width: `${progress * 100}%` }}
            />
          </div>
        </>
      )}
    </main>
  )
}
