import { useQuery, type UseQueryResult } from '@tanstack/react-query'

import { getGlobalStats } from '../lib/apiClient'
import type { GlobalStats } from '../lib/types'

/**
 * Fetches the live global-impact counters for the Home page.
 * Refetches periodically so the "chains broken today" counter feels alive
 * without the visitor needing to reload the page.
 */
export function useGlobalStats(): UseQueryResult<GlobalStats, unknown> {
  return useQuery({
    queryKey: ['global-stats'],
    queryFn: getGlobalStats,
    staleTime: 30_000,
    refetchInterval: 60_000,
    retry: 1,
  })
}
