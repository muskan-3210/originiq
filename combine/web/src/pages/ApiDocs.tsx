import { useState, type FormEvent, type ReactNode } from 'react'

import { API_BASE_URL } from '../lib/apiClient'
import { VerdictBadge } from '../components/VerdictBadge'

const SWAGGER_URL = `${API_BASE_URL}/docs`

const GLOBAL_STATS_RESPONSE = `{
  "chains_broken_today": 1042,
  "chains_broken_total": 58210,
  "countries_covered": 61
}`

const LEADERBOARD_RESPONSE = `{
  "scope": "global",
  "entries": [
    { "rank": 1, "display_name": "Amara O.", "catch_count": 812, "country": "NG" },
    { "rank": 2, "display_name": "Priya S.", "catch_count": 774, "country": "IN" }
  ]
}`

const ANALYZE_RESPONSE = `{
  "id": "b3f1c2e4-...",
  "verdict": "false",
  "cached": false,
  "origin": {
    "platform": "whatsapp",
    "country": "IN",
    "date": "2020-03-14",
    "tags": ["health-misinformation", "covid-era"],
    "hops_traced": 6
  },
  "mutations": [
    { "version": 2, "country": "BR", "date": "2020-04-02", "text_excerpt": "...", "similarity_to_origin": 0.81 }
  ],
  "damage": [
    { "label": "People misled", "value": 47000, "description": "...", "source_name": "Reuters", "source_url": "https://..." }
  ],
  "truth_card_ready": true
}`

const ERROR_SHAPE = `{ "error": { "code": "string", "message": "human-readable message" } }`

export function ApiDocs() {
  return (
    <div className="mx-auto max-w-4xl px-5 py-16">
      <header className="text-center">
        <h1 className="font-display text-3xl font-medium text-textPrimary">API docs</h1>
        <p className="mx-auto mt-3 max-w-2xl text-sm text-textSecondary">
          ORACLE's backend exposes a small public API for checking content and reading aggregate impact data.
          The examples below call whatever backend this dashboard is currently configured against.
        </p>
      </header>

      <section className="mt-12 rounded-card border border-hairline border-borderDefault bg-surface p-6">
        <h2 className="font-display text-lg font-medium text-textPrimary">Base URL &amp; interactive docs</h2>
        <p className="mt-2 text-sm text-textSecondary">
          Every endpoint below is relative to <InlineCode>{API_BASE_URL}</InlineCode>. The backend also serves a full,
          auto-generated Swagger UI (every request/response schema, tried live from the browser) at:
        </p>
        <a
          href={SWAGGER_URL}
          target="_blank"
          rel="noreferrer"
          className="mt-3 inline-flex items-center gap-2 text-sm text-gold underline-offset-2 hover:underline"
        >
          {SWAGGER_URL}
          <ExternalLinkIcon />
        </a>
        <p className="mt-3 text-xs text-textMuted">
          If this link doesn&rsquo;t load, the configured backend (<InlineCode>VITE_API_BASE_URL</InlineCode>) isn&rsquo;t
          running or reachable from here yet.
        </p>
      </section>

      <section className="mt-8 rounded-card border border-hairline border-borderDefault bg-surface p-6">
        <h2 className="font-display text-lg font-medium text-textPrimary">Authentication &amp; errors</h2>
        <p className="mt-2 text-sm text-textSecondary">
          Authentication is optional almost everywhere. Pass a Firebase ID token as{' '}
          <InlineCode>Authorization: Bearer &lt;token&gt;</InlineCode> to attribute a request to a user for
          history/leaderboard purposes — anonymous requests are still served in full. Every error response shares one
          shape:
        </p>
        <div className="mt-3">
          <CodeBlock code={ERROR_SHAPE} label="error shape" />
        </div>
      </section>

      <section className="mt-8 space-y-8">
        <EndpointDocs
          method="POST"
          path="/api/analyze"
          description="Analyzes submitted content (text, URL, or image) and returns its full origin, mutation, and damage story. Auth optional."
          curl={`curl -X POST "${API_BASE_URL}/analyze" \\\n  -F "type=text" \\\n  -F "content=Breaking: scientists confirm 5G towers cause..."`}
          response={ANALYZE_RESPONSE}
        >
          <div className="flex flex-wrap items-center gap-2 text-xs text-textMuted">
            <span>The four possible <InlineCode>verdict</InlineCode> values render as:</span>
            <VerdictBadge verdict="false" />
            <VerdictBadge verdict="misleading" />
            <VerdictBadge verdict="true" />
            <VerdictBadge verdict="unverified" />
          </div>
        </EndpointDocs>
        <EndpointDocs
          method="GET"
          path="/api/leaderboard?scope=&limit="
          description="Returns the top catchers for a scope (global | country | school), up to 100 entries. No auth required."
          curl={`curl "${API_BASE_URL}/leaderboard?scope=global&limit=10"`}
          response={LEADERBOARD_RESPONSE}
        />
        <EndpointDocs
          method="GET"
          path="/api/stats/global"
          description="Powers this dashboard's live counter: chains broken today, all-time, and countries covered. No auth required."
          curl={`curl "${API_BASE_URL}/stats/global"`}
          response={GLOBAL_STATS_RESPONSE}
        />
      </section>

      <section className="mt-12 rounded-card border border-hairline border-borderDefault bg-surfaceRaised p-6">
        <h2 className="font-display text-lg font-medium text-textPrimary">Request an API key</h2>
        <p className="mt-2 text-sm text-textSecondary">
          Building on ORACLE? Tell us about it. This form is UI only for now — submitting it isn&rsquo;t wired up to
          anything yet, so nothing is sent anywhere.
        </p>
        <div className="mt-5">
          <ApiKeyRequestForm />
        </div>
      </section>
    </div>
  )
}

interface EndpointDocsProps {
  method: 'GET' | 'POST'
  path: string
  description: string
  curl: string
  response: string
  children?: ReactNode
}

function EndpointDocs({ method, path, description, curl, response, children }: EndpointDocsProps) {
  const methodStyle =
    method === 'POST' ? 'border-teal/40 bg-teal/15 text-teal' : 'border-gold/40 bg-gold/15 text-gold'

  return (
    <div className="rounded-card border border-hairline border-borderDefault bg-surface p-6">
      <div className="flex flex-wrap items-center gap-3">
        <span className={`rounded-pill border border-hairline px-2.5 py-1 font-mono text-xs ${methodStyle}`}>{method}</span>
        <code className="font-mono text-sm text-textPrimary">{path}</code>
      </div>
      <p className="mt-3 text-sm text-textSecondary">{description}</p>

      <div className="mt-4 grid grid-cols-1 gap-4 lg:grid-cols-2">
        <div>
          <p className="mb-2 text-xs text-textMuted">Request</p>
          <CodeBlock code={curl} label="curl" />
        </div>
        <div>
          <p className="mb-2 text-xs text-textMuted">Response 200</p>
          <CodeBlock code={response} label="json" />
        </div>
      </div>

      {children ? <div className="mt-4">{children}</div> : null}
    </div>
  )
}

function CodeBlock({ code, label }: { code: string; label?: string }) {
  const [copied, setCopied] = useState(false)

  async function handleCopy() {
    try {
      await navigator.clipboard.writeText(code)
      setCopied(true)
      window.setTimeout(() => setCopied(false), 1500)
    } catch {
      // Clipboard API can be unavailable (e.g. insecure context) — fail quietly, never crash.
    }
  }

  return (
    <div className="overflow-hidden rounded-card border border-hairline border-borderDefault bg-base">
      <div className="flex items-center justify-between border-b border-hairline border-borderDefault px-4 py-2">
        <span className="text-xs text-textMuted">{label ?? 'code'}</span>
        <button
          type="button"
          onClick={() => void handleCopy()}
          className="text-xs text-textSecondary transition-colors hover:text-gold"
        >
          {copied ? 'Copied' : 'Copy'}
        </button>
      </div>
      <pre className="overflow-x-auto px-4 py-4 text-xs leading-relaxed text-textPrimary">
        <code className="font-mono">{code}</code>
      </pre>
    </div>
  )
}

function InlineCode({ children }: { children: ReactNode }) {
  return (
    <code className="rounded bg-surfaceRaised px-1.5 py-0.5 font-mono text-[0.85em] text-textPrimary">{children}</code>
  )
}

function ApiKeyRequestForm() {
  const [submitted, setSubmitted] = useState(false)

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setSubmitted(true)
  }

  const fieldClasses =
    'w-full rounded-button border border-hairline border-borderDefault bg-surface px-4 py-3 text-sm text-textPrimary placeholder:text-textMuted focus:border-borderStrong focus:outline-none'

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label htmlFor="req-email" className="mb-1 block text-sm text-textSecondary">
          Email
        </label>
        <input id="req-email" name="email" type="email" required placeholder="you@example.com" className={fieldClasses} />
      </div>
      <div>
        <label htmlFor="req-org" className="mb-1 block text-sm text-textSecondary">
          Organization
        </label>
        <input id="req-org" name="org" type="text" required placeholder="Your organization or project" className={fieldClasses} />
      </div>
      <div>
        <label htmlFor="req-use-case" className="mb-1 block text-sm text-textSecondary">
          Use case
        </label>
        <textarea
          id="req-use-case"
          name="useCase"
          required
          rows={3}
          placeholder="How would you use the ORACLE API?"
          className={fieldClasses}
        />
      </div>
      <div className="flex flex-wrap items-center gap-4">
        <button
          type="submit"
          className="rounded-button bg-gold px-5 py-3 text-sm font-medium text-base transition-opacity hover:opacity-90"
        >
          Request access
        </button>
        {submitted ? (
          <p role="status" className="text-sm text-teal">
            Thanks — this form isn&rsquo;t wired up yet. Email{' '}
            <a href="mailto:hello@oracle-app.example" className="underline underline-offset-2">
              hello@oracle-app.example
            </a>{' '}
            directly and we&rsquo;ll follow up.
          </p>
        ) : null}
      </div>
    </form>
  )
}

function ExternalLinkIcon() {
  return (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" aria-hidden="true">
      <path d="M14 4h6v6M20 4L10 14M19 13v5a2 2 0 01-2 2H6a2 2 0 01-2-2V8a2 2 0 012-2h5" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  )
}
