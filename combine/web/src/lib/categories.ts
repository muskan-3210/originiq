import type { ContentCategory } from './types'

export const CATEGORIES: ContentCategory[] = ['health', 'election', 'disaster', 'deepfake', 'other']

export const CATEGORY_LABEL: Record<ContentCategory, string> = {
  health: 'Health',
  election: 'Election',
  disaster: 'Disaster',
  deepfake: 'Deepfake',
  other: 'Other',
}

/**
 * Categorical colors for map markers, the legend, and filter chips.
 *
 * health / election / disaster / deepfake were chosen and validated together as a
 * CVD-safe categorical set (lightness band, chroma floor, all-pairs CVD separation,
 * and contrast against the `surface` (#17142B) token) — distinct from the colors
 * already reserved for verdict states (danger/teal/amber) so a category swatch is
 * never mistaken for a verdict. `other` is an intentional neutral (the existing
 * `textMuted` token): a catch-all bucket is deliberately not designed to compete
 * visually with real categories. Every place a swatch appears, it ships with its
 * text label too — color is never the only signal.
 */
export const CATEGORY_COLOR: Record<ContentCategory, string> = {
  health: '#3A82D1',
  election: '#8C7DF2',
  disaster: '#E0629E',
  deepfake: '#C97452',
  other: '#6E698F',
}
