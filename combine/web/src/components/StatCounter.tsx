import { useEffect, useRef, useState } from 'react'
import { easeCubicOut, format, interpolateNumber } from 'd3'

interface StatCounterProps {
  value: number
  label: string
  /** Animation duration in ms. Ignored when the visitor prefers reduced motion. */
  duration?: number
  className?: string
}

const formatCount = format(',d')

/** Animated count-up number (via d3's interpolator + easing), with a reduced-motion fallback. */
export function StatCounter({ value, label, duration = 1400, className = '' }: StatCounterProps) {
  const [displayValue, setDisplayValue] = useState(0)
  const previousValue = useRef(0)

  useEffect(() => {
    const prefersReducedMotion =
      typeof window !== 'undefined' && window.matchMedia('(prefers-reduced-motion: reduce)').matches

    if (prefersReducedMotion) {
      setDisplayValue(value)
      previousValue.current = value
      return
    }

    const from = previousValue.current
    const to = value
    if (from === to) return

    const interpolator = interpolateNumber(from, to)
    const start = performance.now()
    let frameId: number

    function tick(now: number) {
      const elapsed = now - start
      const t = Math.min(1, elapsed / duration)
      setDisplayValue(Math.round(interpolator(easeCubicOut(t))))
      if (t < 1) {
        frameId = requestAnimationFrame(tick)
      } else {
        previousValue.current = to
      }
    }

    frameId = requestAnimationFrame(tick)
    return () => cancelAnimationFrame(frameId)
  }, [value, duration])

  return (
    <div className={`text-center ${className}`}>
      <p className="font-display text-4xl font-medium tabular-nums text-textPrimary sm:text-5xl">
        {formatCount(displayValue)}
      </p>
      <p className="mt-2 text-sm text-textSecondary">{label}</p>
    </div>
  )
}
