import axios, { type AxiosError, type AxiosInstance } from 'axios'

import type { ApiErrorShape, GlobalStats, LeaderboardResponse, LeaderboardScope } from './types'

/** Base URL of the ORACLE backend. Falls back to a sensible local dev default. */
export const API_BASE_URL: string = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8000/api'

export const apiClient: AxiosInstance = axios.create({
  baseURL: API_BASE_URL,
  timeout: 15_000,
  headers: {
    Accept: 'application/json',
  },
})

/**
 * Normalizes any axios/network failure into one human-readable, non-technical message,
 * matching the product's copy rules (§8.7 of the PRD): what happened, no jargon, no
 * "Error:" prefix, no raw stack traces.
 */
export function getApiErrorMessage(error: unknown): string {
  if (axios.isAxiosError(error)) {
    const axiosError = error as AxiosError<ApiErrorShape>
    const backendMessage = axiosError.response?.data?.error?.message
    if (backendMessage) return backendMessage

    if (axiosError.response?.status === 429) {
      return "You're checking things quickly — give it a minute and try again."
    }
    if (axiosError.code === 'ECONNABORTED') {
      return 'The request took too long to respond. The backend may be waking up — try again shortly.'
    }
    if (!axiosError.response) {
      return 'Could not reach the ORACLE backend. It may be offline or unreachable from here.'
    }
    return `The request failed (status ${axiosError.response.status}). Please try again.`
  }
  if (error instanceof Error) return error.message
  return 'Something unexpected happened. Please try again.'
}

/** GET /api/stats/global — powers the web dashboard's live counter. */
export async function getGlobalStats(): Promise<GlobalStats> {
  const { data } = await apiClient.get<GlobalStats>('/stats/global')
  return data
}

/** GET /api/leaderboard?scope=&limit= */
export async function getLeaderboard(
  scope: LeaderboardScope = 'global',
  limit = 50,
): Promise<LeaderboardResponse> {
  const { data } = await apiClient.get<LeaderboardResponse>('/leaderboard', {
    params: { scope, limit },
  })
  return data
}

/** GET /health — not under the /api prefix; used for a lightweight reachability check. */
export async function getHealth(): Promise<{ status: string }> {
  const healthUrl = `${API_BASE_URL.replace(/\/api\/?$/, '')}/health`
  const { data } = await axios.get<{ status: string }>(healthUrl, { timeout: 5_000 })
  return data
}
