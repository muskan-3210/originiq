import { useQuery, type UseQueryResult } from '@tanstack/react-query'

import { getLeaderboard } from '../lib/apiClient'
import type { LeaderboardResponse, LeaderboardScope } from '../lib/types'

/** Fetches the leaderboard for a given scope (global | country | school). */
export function useLeaderboard(scope: LeaderboardScope, limit = 50): UseQueryResult<LeaderboardResponse, unknown> {
  return useQuery({
    queryKey: ['leaderboard', scope, limit],
    queryFn: () => getLeaderboard(scope, limit),
    staleTime: 30_000,
    retry: 1,
  })
}
