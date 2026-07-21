import { useMemo, useState } from 'react'
import { Bar, BarChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts'

import { useLeaderboard } from '../hooks/useLeaderboard'
import { LeaderboardTable } from '../components/LeaderboardTable'
import { ErrorState } from '../components/ErrorState'
import { Loading } from '../components/Loading'
import { getApiErrorMessage } from '../lib/apiClient'
import type { LeaderboardScope } from '../lib/types'

const SCOPES: Array<{ value: LeaderboardScope; label: string }> = [
  { value: 'global', label: 'Global' },
  { value: 'country', label: 'Country' },
  { value: 'school', label: 'School' },
]

const LIMIT = 50
const CHART_TOP_N = 8
const MAX_CHART_LABEL_LENGTH = 16

export function Leaderboard() {
  const [scope, setScope] = useState<LeaderboardScope>('global')
  const { data, isError, error, refetch } = useLeaderboard(scope, LIMIT)

  // Covers the initial fetch AND a fetch "paused" by react-query's network-mode detection
  // (e.g. a transient offline blip) — it can sit in paused indefinitely without ever
  // flipping to isError, so `!data && !isError` is the robust "still waiting" signal,
  // rather than relying on isLoading alone.
  const isWaiting = !data && !isError

  const entries = useMemo(() => data?.entries ?? [], [data])

  const chartData = useMemo(
    () =>
      entries.slice(0, CHART_TOP_N).map((entry) => ({
        name:
          entry.display_name.length > MAX_CHART_LABEL_LENGTH
            ? `${entry.display_name.slice(0, MAX_CHART_LABEL_LENGTH - 1)}…`
            : entry.display_name,
        catches: entry.catch_count,
      })),
    [entries],
  )

  return (
    <div className="mx-auto max-w-5xl px-5 py-16">
      <header className="text-center">
        <h1 className="font-display text-3xl font-medium text-textPrimary">Leaderboard</h1>
        <p className="mx-auto mt-3 max-w-xl text-sm text-textSecondary">
          Everyone who helped break a chain of misinformation, ranked by chains broken.
        </p>
      </header>

      <div role="tablist" aria-label="Leaderboard scope" className="mt-8 flex justify-center gap-2">
        {SCOPES.map((option) => (
          <button
            key={option.value}
            type="button"
            role="tab"
            aria-selected={scope === option.value}
            onClick={() => setScope(option.value)}
            className={`rounded-pill border border-hairline px-4 py-2 text-sm transition-colors ${
              scope === option.value
                ? 'border-gold bg-gold/10 text-textPrimary'
                : 'border-borderDefault bg-surface text-textSecondary hover:border-borderStrong hover:text-textPrimary'
            }`}
          >
            {option.label}
          </button>
        ))}
      </div>

      {isError ? (
        <ErrorState className="mt-10" message={getApiErrorMessage(error)} onRetry={() => void refetch()} />
      ) : (
        <>
          {isWaiting ? (
            <Loading label="Loading top entries…" className="mt-10 justify-center" />
          ) : chartData.length > 0 ? (
            <div className="mt-10 rounded-card border border-hairline border-borderDefault bg-surface p-6">
              <p className="mb-4 text-sm text-textSecondary">Top {chartData.length} at a glance</p>
              <div style={{ width: '100%', height: Math.max(180, chartData.length * 36) }}>
                <ResponsiveContainer>
                  <BarChart
                    data={chartData}
                    layout="vertical"
                    margin={{ top: 0, right: 24, bottom: 0, left: 0 }}
                    barCategoryGap={10}
                  >
                    <CartesianGrid horizontal={false} stroke="#2A2650" />
                    <XAxis
                      type="number"
                      allowDecimals={false}
                      tick={{ fill: '#6E698F', fontSize: 12 }}
                      axisLine={{ stroke: '#2A2650' }}
                      tickLine={false}
                    />
                    <YAxis
                      type="category"
                      dataKey="name"
                      width={110}
                      tick={{ fill: '#A9A3C9', fontSize: 12 }}
                      axisLine={{ stroke: '#2A2650' }}
                      tickLine={false}
                    />
                    <Tooltip
                      cursor={{ fill: 'rgba(255,255,255,0.04)' }}
                      contentStyle={{ background: '#201C3B', border: '1px solid #2A2650', borderRadius: 8, fontSize: 12 }}
                      labelStyle={{ color: '#F5F3FF' }}
                      itemStyle={{ color: '#A9A3C9' }}
                    />
                    <Bar dataKey="catches" name="Chains broken" fill="#FFC857" radius={[4, 4, 4, 4]} maxBarSize={18} />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </div>
          ) : null}

          <div className="mt-8">
            <LeaderboardTable entries={entries} isLoading={isWaiting} />
          </div>
        </>
      )}
    </div>
  )
}
