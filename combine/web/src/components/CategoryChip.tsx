import type { ContentCategory } from '../lib/types'
import { CATEGORY_COLOR, CATEGORY_LABEL } from '../lib/categories'

interface CategoryChipProps {
  category: ContentCategory
  active: boolean
  onToggle: (category: ContentCategory) => void
}

/** Toggleable pill filter chip, tagged with the category's swatch + label (never color alone). */
export function CategoryChip({ category, active, onToggle }: CategoryChipProps) {
  return (
    <button
      type="button"
      aria-pressed={active}
      onClick={() => onToggle(category)}
      className={`inline-flex items-center gap-2 rounded-pill border border-hairline px-4 py-2 text-sm transition-colors ${
        active
          ? 'border-gold bg-gold/10 text-textPrimary'
          : 'border-borderDefault bg-surface text-textSecondary hover:border-borderStrong hover:text-textPrimary'
      }`}
    >
      <span
        aria-hidden="true"
        className="h-2 w-2 rounded-pill"
        style={{ backgroundColor: CATEGORY_COLOR[category], opacity: active ? 1 : 0.6 }}
      />
      {CATEGORY_LABEL[category]}
    </button>
  )
}
