import type { LeaderboardEntry } from '../lib/types'
import { EmptyState } from './EmptyState'

interface LeaderboardTableProps {
  entries: LeaderboardEntry[]
  isLoading: boolean
}

const COLUMNS = ['Rank', 'Name', 'Country', 'Chains broken']

function SkeletonRows() {
  return (
    <>
      {Array.from({ length: 6 }).map((_, index) => (
        <tr key={index} className="border-b border-hairline border-borderDefault last:border-none">
          <td className="px-4 py-4">
            <div className="h-4 w-6 animate-pulse rounded bg-surfaceRaised" />
          </td>
          <td className="px-4 py-4">
            <div className="h-4 w-32 animate-pulse rounded bg-surfaceRaised" />
          </td>
          <td className="px-4 py-4">
            <div className="h-4 w-10 animate-pulse rounded bg-surfaceRaised" />
          </td>
          <td className="px-4 py-4 text-right">
            <div className="ml-auto h-4 w-16 animate-pulse rounded bg-surfaceRaised" />
          </td>
        </tr>
      ))}
    </>
  )
}

/** Ranked leaderboard table with a loading skeleton and an empty state. */
export function LeaderboardTable({ entries, isLoading }: LeaderboardTableProps) {
  if (!isLoading && entries.length === 0) {
    return (
      <EmptyState
        title="No entries yet"
        description="Once people start breaking chains of misinformation, the ranking will appear here."
      />
    )
  }

  return (
    <div className="overflow-x-auto rounded-card border border-hairline border-borderDefault">
      <table className="w-full text-left text-sm">
        <thead>
          <tr className="border-b border-hairline border-borderDefault bg-surface text-textSecondary">
            {COLUMNS.map((column, index) => (
              <th
                key={column}
                scope="col"
                className={`px-4 py-3 font-body font-normal ${index === COLUMNS.length - 1 ? 'text-right' : ''}`}
              >
                {column}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {isLoading ? (
            <SkeletonRows />
          ) : (
            entries.map((entry) => (
              <tr
                key={`${entry.rank}-${entry.display_name}`}
                className="border-b border-hairline border-borderDefault last:border-none hover:bg-surface/60"
              >
                <td className={`px-4 py-3 font-display font-medium ${entry.rank <= 3 ? 'text-gold' : 'text-textPrimary'}`}>
                  {entry.rank}
                </td>
                <td className="px-4 py-3 text-textPrimary">{entry.display_name}</td>
                <td className="px-4 py-3 text-textSecondary">{entry.country ?? '—'}</td>
                <td className="px-4 py-3 text-right tabular-nums text-textPrimary">
                  {entry.catch_count.toLocaleString()}
                </td>
              </tr>
            ))
          )}
        </tbody>
      </table>
    </div>
  )
}
