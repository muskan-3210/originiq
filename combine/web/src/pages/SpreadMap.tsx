import { useMemo, useState } from 'react'
import Map, { Marker, NavigationControl } from 'react-map-gl'
import 'mapbox-gl/dist/mapbox-gl.css'

import { CategoryChip } from '../components/CategoryChip'
import { CATEGORIES, CATEGORY_COLOR, CATEGORY_LABEL } from '../lib/categories'
import type { ContentCategory } from '../lib/types'

type DateRangeValue = '7' | '30' | '90' | 'all'

const DATE_RANGE_OPTIONS: Array<{ value: DateRangeValue; label: string }> = [
  { value: '7', label: 'Last 7 days' },
  { value: '30', label: 'Last 30 days' },
  { value: '90', label: 'Last 90 days' },
  { value: 'all', label: 'All time' },
]

interface SpreadPoint {
  id: string
  lng: number
  lat: number
  label: string
  category: ContentCategory
  date: string
}

function daysAgo(n: number): string {
  const date = new Date()
  date.setDate(date.getDate() - n)
  return date.toISOString().slice(0, 10)
}

/**
 * Illustrative sample locations — the API spec (docs/PRD.md §10) does not yet define a
 * public spread-geodata endpoint, so these demonstrate the map/filters working end to end
 * without asserting any real, specific misinformation incident. Swap for a live feed
 * (e.g. a future GET /api/spread) once one exists; the filtering logic below already
 * operates on this shape.
 */
const SAMPLE_SPREAD_POINTS: SpreadPoint[] = [
  { id: 'p1', lng: 77.1, lat: 28.6, label: 'New Delhi, India', category: 'health', date: daysAgo(4) },
  { id: 'p2', lng: -46.6, lat: -23.5, label: 'São Paulo, Brazil', category: 'election', date: daysAgo(12) },
  { id: 'p3', lng: 31.2, lat: 30.0, label: 'Cairo, Egypt', category: 'disaster', date: daysAgo(20) },
  { id: 'p4', lng: 139.7, lat: 35.7, label: 'Tokyo, Japan', category: 'deepfake', date: daysAgo(6) },
  { id: 'p5', lng: -0.1, lat: 51.5, label: 'London, United Kingdom', category: 'other', date: daysAgo(45) },
  { id: 'p6', lng: 36.8, lat: -1.3, label: 'Nairobi, Kenya', category: 'health', date: daysAgo(70) },
  { id: 'p7', lng: -99.1, lat: 19.4, label: 'Mexico City, Mexico', category: 'election', date: daysAgo(2) },
  { id: 'p8', lng: 103.8, lat: 1.35, label: 'Singapore', category: 'deepfake', date: daysAgo(85) },
  { id: 'p9', lng: 151.2, lat: -33.9, label: 'Sydney, Australia', category: 'disaster', date: daysAgo(30) },
  { id: 'p10', lng: 28.0, lat: -26.2, label: 'Johannesburg, South Africa', category: 'other', date: daysAgo(15) },
  { id: 'p11', lng: -74.0, lat: 40.7, label: 'New York, United States', category: 'health', date: daysAgo(9) },
  { id: 'p12', lng: 37.6, lat: 55.75, label: 'Moscow, Russia', category: 'election', date: daysAgo(60) },
]

export function SpreadMap() {
  const mapboxToken = import.meta.env.VITE_MAPBOX_TOKEN
  const hasToken = Boolean(mapboxToken)

  const [activeCategories, setActiveCategories] = useState<Set<ContentCategory>>(() => new Set(CATEGORIES))
  const [dateRange, setDateRange] = useState<DateRangeValue>('90')
  const [mapFailed, setMapFailed] = useState(false)

  function toggleCategory(category: ContentCategory) {
    setActiveCategories((previous) => {
      const next = new Set(previous)
      if (next.has(category)) {
        next.delete(category)
      } else {
        next.add(category)
      }
      return next
    })
  }

  const cutoffDate = useMemo(() => {
    if (dateRange === 'all') return null
    const date = new Date()
    date.setDate(date.getDate() - Number(dateRange))
    return date
  }, [dateRange])

  const visiblePoints = useMemo(
    () =>
      SAMPLE_SPREAD_POINTS.filter((point) => {
        if (!activeCategories.has(point.category)) return false
        if (cutoffDate && new Date(point.date) < cutoffDate) return false
        return true
      }),
    [activeCategories, cutoffDate],
  )

  return (
    <div className="mx-auto max-w-6xl px-5 py-16">
      <header className="text-center">
        <h1 className="font-display text-3xl font-medium text-textPrimary">Spread map</h1>
        <p className="mx-auto mt-3 max-w-xl text-sm text-textSecondary">
          Where traced misinformation has crossed borders and platforms, filtered by category and time.
        </p>
      </header>

      <div className="mt-8 flex flex-wrap items-center justify-center gap-2">
        {CATEGORIES.map((category) => (
          <CategoryChip key={category} category={category} active={activeCategories.has(category)} onToggle={toggleCategory} />
        ))}
      </div>

      <div className="mt-3 flex flex-wrap items-center justify-center gap-2">
        {DATE_RANGE_OPTIONS.map((option) => (
          <button
            key={option.value}
            type="button"
            aria-pressed={dateRange === option.value}
            onClick={() => setDateRange(option.value)}
            className={`rounded-pill border border-hairline px-3 py-1.5 text-xs transition-colors ${
              dateRange === option.value
                ? 'border-gold bg-gold/10 text-textPrimary'
                : 'border-borderDefault bg-surface text-textSecondary hover:border-borderStrong hover:text-textPrimary'
            }`}
          >
            {option.label}
          </button>
        ))}
      </div>

      <div className="mt-8 overflow-hidden rounded-card border border-hairline border-borderDefault">
        {hasToken && !mapFailed ? (
          <div style={{ height: 520 }}>
            <Map
              mapboxAccessToken={mapboxToken}
              initialViewState={{ longitude: 10, latitude: 20, zoom: 1.1 }}
              mapStyle="mapbox://styles/mapbox/dark-v11"
              projection={{ name: 'globe' }}
              style={{ width: '100%', height: '100%' }}
              onError={() => setMapFailed(true)}
            >
              <NavigationControl position="top-right" />
              {visiblePoints.map((point) => (
                <Marker key={point.id} longitude={point.lng} latitude={point.lat} anchor="center">
                  <span
                    title={`${point.label} — ${CATEGORY_LABEL[point.category]}`}
                    aria-label={`${point.label} — ${CATEGORY_LABEL[point.category]}`}
                    className="block h-3 w-3 rounded-full ring-2 ring-base"
                    style={{ backgroundColor: CATEGORY_COLOR[point.category] }}
                  />
                </Marker>
              ))}
            </Map>
          </div>
        ) : (
          <MapFallbackPanel hasError={mapFailed} />
        )}
      </div>

      {hasToken && !mapFailed ? (
        <p className="mt-4 text-center text-xs text-textMuted">
          Showing {visiblePoints.length} illustrative sample location{visiblePoints.length === 1 ? '' : 's'} — connect a
          live spread-tracking feed to populate this in real time.
        </p>
      ) : null}

      <div className="mt-6 flex flex-wrap items-center justify-center gap-4 text-xs text-textSecondary" aria-label="Legend">
        {CATEGORIES.map((category) => (
          <span key={category} className="inline-flex items-center gap-2">
            <span aria-hidden="true" className="h-2 w-2 rounded-full" style={{ backgroundColor: CATEGORY_COLOR[category] }} />
            {CATEGORY_LABEL[category]}
          </span>
        ))}
      </div>
    </div>
  )
}

function MapFallbackPanel({ hasError }: { hasError: boolean }) {
  return (
    <div className="flex h-[420px] flex-col items-center justify-center gap-3 bg-surface px-6 text-center sm:h-[520px]">
      <span
        aria-hidden="true"
        className="flex h-12 w-12 items-center justify-center rounded-pill border border-hairline border-borderStrong text-gold"
      >
        <GlobeIcon />
      </span>
      <p className="font-display text-base font-medium text-textPrimary">
        {hasError ? 'The map could not load' : 'Add a Mapbox token to view the live spread map'}
      </p>
      <p className="max-w-sm text-sm text-textSecondary">
        {hasError
          ? 'The Mapbox token may be invalid, or the map tiles could not be reached from here.'
          : 'Set VITE_MAPBOX_TOKEN in your .env file with a token from account.mapbox.com, then restart the dev server.'}
      </p>
    </div>
  )
}

function GlobeIcon() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" aria-hidden="true">
      <circle cx="12" cy="12" r="9" />
      <path d="M3 12h18M12 3c2.5 2.6 4 6 4 9s-1.5 6.4-4 9c-2.5-2.6-4-6-4-9s1.5-6.4 4-9z" />
    </svg>
  )
}
