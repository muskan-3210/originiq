'use client'

import { createContext, useContext, useMemo, useState, type ReactNode } from 'react'

import type { Analysis, ScanRequest } from '@/lib/types'

interface FlowState {
  scanRequest: ScanRequest | null
  setScanRequest: (request: ScanRequest | null) => void
  analysis: Analysis | null
  setAnalysis: (analysis: Analysis | null) => void
}

const FlowContext = createContext<FlowState | null>(null)

export function FlowProvider({ children }: { children: ReactNode }) {
  const [scanRequest, setScanRequest] = useState<ScanRequest | null>(null)
  const [analysis, setAnalysis] = useState<Analysis | null>(null)

  const value = useMemo(
    () => ({ scanRequest, setScanRequest, analysis, setAnalysis }),
    [scanRequest, analysis],
  )

  return <FlowContext.Provider value={value}>{children}</FlowContext.Provider>
}

export function useFlow(): FlowState {
  const ctx = useContext(FlowContext)
  if (!ctx) throw new Error('useFlow must be used within a FlowProvider')
  return ctx
}
