/**
 * TypeScript interfaces mirroring the ORACLE backend API (see docs/PRD.md §10).
 * Keep these in sync with the FastAPI Pydantic schemas — this file is the single
 * source of truth for response shapes on the web dashboard.
 */

/** A claim's truthfulness outcome. `unverified` means "no match yet", never a guess. */
export type Verdict = 'false' | 'misleading' | 'true' | 'unverified'

/** GET /api/stats/global */
export interface GlobalStats {
  chains_broken_today: number
  chains_broken_total: number
  countries_covered: number
}

/** One row of GET /api/leaderboard */
export interface LeaderboardEntry {
  rank: number
  display_name: string
  catch_count: number
  country: string | null
}

export type LeaderboardScope = 'global' | 'country' | 'school'

/** GET /api/leaderboard response envelope */
export interface LeaderboardResponse {
  scope: LeaderboardScope
  entries: LeaderboardEntry[]
}

/** Misinformation category tags, used by both the knowledge base and the spread map filters. */
export type ContentCategory = 'health' | 'election' | 'disaster' | 'deepfake' | 'other'

export type Platform = 'whatsapp' | 'facebook' | 'twitter' | 'tiktok' | 'other'

/** Where and when a matched claim was first traced to. */
export interface Origin {
  platform: Platform | (string & {})
  country: string
  date: string
  tags: string[]
  hops_traced: number
}

/** One recorded variant of a claim as it mutated while spreading. */
export interface Mutation {
  version: number
  country: string
  date: string
  text_excerpt: string
  similarity_to_origin: number
}

/** One documented real-world harm statistic, always sourced. */
export interface DamageStat {
  label: string
  value: number
  description: string
  source_name: string
  source_url: string
}

/** POST /api/analyze response — the full origin/mutation/damage story for a submission. */
export interface Analysis {
  id: string
  verdict: Verdict
  cached: boolean
  origin: Origin | null
  mutations: Mutation[]
  damage: DamageStat[]
  truth_card_ready: boolean
}

/** Shared error envelope returned by every ORACLE API error response. */
export interface ApiErrorShape {
  error: {
    code: string
    message: string
  }
}
