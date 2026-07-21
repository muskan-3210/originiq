'use client'

import type { ButtonHTMLAttributes } from 'react'

export function SecondaryButton({
  children,
  className = '',
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement>) {
  return (
    <button
      type="button"
      className={`flex items-center justify-center gap-2 rounded-button border border-line-strong bg-transparent px-6 py-3 font-display text-sm font-medium text-ink transition active:scale-[0.98] disabled:opacity-60 ${className}`}
      {...props}
    >
      {children}
    </button>
  )
}
