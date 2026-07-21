'use client'

import { useRouter } from 'next/navigation'
import { useState } from 'react'

import { useFlow } from '@/context/FlowContext'
import { COPY } from '@/lib/constants'
import { looksLikeUrl } from '@/lib/format'
import { PrimaryButton } from '@/components/PrimaryButton'

export default function HomePage() {
  const router = useRouter()
  const { setScanRequest } = useFlow()
  const [value, setValue] = useState('')
  const [showEmptyHint, setShowEmptyHint] = useState(false)
  const [photoNote, setPhotoNote] = useState(false)

  function handleScan() {
    const trimmed = value.trim()
    if (!trimmed) {
      setShowEmptyHint(true)
      return
    }
    setShowEmptyHint(false)
    setScanRequest({ kind: looksLikeUrl(trimmed) ? 'url' : 'text', value: trimmed })
    router.push('/scanning')
  }

  async function handlePaste() {
    try {
      const text = await navigator.clipboard.readText()
      if (text) {
        setValue(text)
        setShowEmptyHint(false)
      }
    } catch {
      // Clipboard access denied/unavailable — user can still type or paste manually.
    }
  }

  return (
    <main className="flex flex-1 flex-col justify-center gap-6 px-5 py-10">
      <p className="text-sm text-ink-dim">
        Paste something suspicious — a message, a headline, a claim — and we&apos;ll trace where it
        came from.
      </p>

      <div className="rounded-card border border-line bg-surface p-4">
        <textarea
          value={value}
          onChange={(e) => setValue(e.target.value)}
          placeholder="Paste a message, headline, or claim…"
          rows={5}
          className="w-full resize-none bg-transparent text-sm text-ink placeholder:text-ink-faint"
        />
        <div className="mt-3 flex items-center gap-2">
          <button
            type="button"
            aria-label="Paste from clipboard"
            onClick={handlePaste}
            className="flex h-11 w-11 items-center justify-center rounded-full bg-surface-raised text-ink-dim transition hover:text-ink"
          >
            <ClipboardIcon />
          </button>
          <button
            type="button"
            aria-label="Upload a photo"
            onClick={() => setPhotoNote(true)}
            className="flex h-11 w-11 items-center justify-center rounded-full bg-surface-raised text-ink-dim transition hover:text-ink"
          >
            <PhotoIcon />
          </button>
        </div>
        {photoNote ? <p className="mt-2 text-xs text-ink-faint">{COPY.photoUploadUnavailable}</p> : null}
      </div>

      <PrimaryButton onClick={handleScan}>Scan for truth</PrimaryButton>

      {showEmptyHint ? (
        <p className="-mt-3 text-center text-xs text-ink-faint">{COPY.pasteHintEmpty}</p>
      ) : null}
    </main>
  )
}

function ClipboardIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" aria-hidden="true">
      <rect x="7" y="4" width="10" height="16" rx="2" stroke="currentColor" strokeWidth="1.6" />
      <path d="M9.5 4V3a1.5 1.5 0 0 1 1.5-1.5h2A1.5 1.5 0 0 1 14.5 3v1" stroke="currentColor" strokeWidth="1.6" />
    </svg>
  )
}

function PhotoIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" aria-hidden="true">
      <rect x="3" y="5" width="18" height="14" rx="2" stroke="currentColor" strokeWidth="1.6" />
      <circle cx="9" cy="10" r="1.6" stroke="currentColor" strokeWidth="1.4" />
      <path d="M3 16.5 8 12l3 2.5 4-4L21 15" stroke="currentColor" strokeWidth="1.6" strokeLinejoin="round" />
    </svg>
  )
}
