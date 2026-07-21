import type { Analysis, ApiErrorShape, ScanInputKind } from './types'

export const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_BASE_URL ?? 'http://localhost:8000/api'

export class ApiError extends Error {
  status?: number
  constructor(message: string, status?: number) {
    super(message)
    this.name = 'ApiError'
    this.status = status
  }
}

async function toApiError(response: Response): Promise<ApiError> {
  try {
    const body = (await response.json()) as ApiErrorShape
    if (body?.error?.message) return new ApiError(body.error.message, response.status)
  } catch {
    // Non-JSON error body — fall through to a generic message.
  }
  if (response.status === 429) {
    return new ApiError("You're checking things quickly — give it a minute and try again.", 429)
  }
  return new ApiError(`The request failed (status ${response.status}). Please try again.`, response.status)
}

/**
 * POST /api/analyze — form-urlencoded `type` + `content` fields (FastAPI
 * `Form(...)` params), NOT a JSON body. See combine/backend/app/api/analyze.py.
 */
export async function analyze(kind: ScanInputKind, value: string): Promise<Analysis> {
  const body = new URLSearchParams({ type: kind, content: value })
  let response: Response
  try {
    response = await fetch(`${API_BASE_URL}/analyze`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body,
    })
  } catch {
    throw new ApiError('Could not reach the ORACLE backend. It may be offline or unreachable from here.')
  }
  if (!response.ok) throw await toApiError(response)
  return (await response.json()) as Analysis
}
