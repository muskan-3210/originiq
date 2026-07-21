'use client'

import type { ButtonHTMLAttributes } from 'react'

export function PrimaryButton({
  children,
  className = '',
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement>) {
  return (
    <button
      type="button"
      className={`flex w-full items-center justify-center gap-2 rounded-button bg-gold px-6 py-4 font-display text-base font-medium text-void transition active:scale-[0.98] disabled:opacity-60 ${className}`}
      {...props}
    >
      {children}
    </button>
  )
}
