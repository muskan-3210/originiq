const PLATFORM_LABELS: Record<string, string> = {
  whatsapp: 'WhatsApp',
  facebook: 'Facebook',
  twitter: 'Twitter',
  tiktok: 'TikTok',
  instagram: 'Instagram',
  blog: 'Blog',
  sms: 'SMS',
}

export function platformLabel(platform: string): string {
  return PLATFORM_LABELS[platform] ?? platform.charAt(0).toUpperCase() + platform.slice(1)
}

/** "2020-01-22" -> "January 2020" */
export function monthYear(isoDate: string): string {
  const date = new Date(isoDate)
  if (Number.isNaN(date.getTime())) return isoDate
  return date.toLocaleDateString('en-US', { month: 'long', year: 'numeric', timeZone: 'UTC' })
}

export function hopsNote(hops: number): string {
  if (hops <= 0) return 'Traced directly to this source.'
  if (hops === 1) return 'Traced through 1 platform before reaching you.'
  return `Traced through ${hops} platforms before reaching you.`
}

export function looksLikeUrl(value: string): boolean {
  return /^(https?:\/\/|www\.)/i.test(value.trim())
}
