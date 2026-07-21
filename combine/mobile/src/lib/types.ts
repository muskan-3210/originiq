/**
 * Mirrors the ORACLE backend API (see docs/PRD.md §10). Keep in sync with
 * the FastAPI Pydantic schemas in combine/backend/app/schemas.
 */

export type Verdict = 'false' | 'misleading' | 'true' | 'unverified'

export interface Origin {
  platform: string
  country: string
  date: string
  tags: string[]
  hops_traced: number
}

export interface Mutation {
  version: number
  country: string
  date: string
  text_excerpt: string
  similarity_to_origin: number
}

export interface DamageStat {
  label: string
  value: number
  description: string
  source_name: string
  source_url: string
}

/** POST /api/analyze response. */
export interface Analysis {
  id: string
  verdict: Verdict
  cached: boolean
  origin: Origin | null
  mutations: Mutation[]
  damage: DamageStat[]
  truth_card_ready: boolean
  /**
   * The originally submitted text/URL. Not part of the wire schema — the
   * API has no notion of "what the user typed," so this is stamped on
   * client-side right after a successful analyze() call.
   */
  claimText?: string
}

export interface ApiErrorShape {
  error: {
    code: string
    message: string
  }
}

export type ScanInputKind = 'text' | 'url'

export interface ScanRequest {
  kind: ScanInputKind
  value: string
}
