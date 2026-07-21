/** Copy and timing constants, ported from the Flutter build's OracleConstants. */

export const COPY = {
  appName: 'Oracle',
  wordmark: 'ORACLE',
  tagline: 'Tracing the truth through time',
  legacyWallEmptyHeadline: 'Start your first catch',
  legacyWallEmptyBody: "Paste anything suspicious and we'll trace it for you",
  truthCardTagline: 'You broke the chain. It ends with you.',
  pasteHintEmpty: 'Paste something first',
  scanTakingLong: 'This is taking longer than usual',
  noDamageRecorded: "Documented impact isn't available for this one yet",
  noFurtherSpread: 'No further spread recorded yet',
  newTerritoryHeadline: 'New territory',
  newTerritoryBody:
    "We couldn't match this to anything we've traced before — it's now part of what we're watching.",
  photoUploadUnavailable: 'Photo upload needs a device photo library — coming soon',
  skipSharing: 'Skip sharing',
} as const

export const TIMING = {
  scanStageDuration: 900,
  storyDwellDuration: 4200,
  storyDwellDurationShort: 2400,
  recentChecksLimit: 3,
} as const
