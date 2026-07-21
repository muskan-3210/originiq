import path from 'node:path'
import { fileURLToPath } from 'node:url'

import tailwindConfig from './tailwind.config.js'

// tailwindcss resolves an unspecified config relative to process.cwd(), not
// this file's location — when this app is launched from a different cwd
// (e.g. a monorepo task runner), that lookup misses tailwind.config.js
// entirely and silently falls back to an empty default config. Importing it
// directly sidesteps that.
//
// That alone isn't enough, though: tailwind.config.js's own `content` globs
// are relative strings, and with no config *file* being loaded from, Tailwind
// has nothing to resolve them against except process.cwd() again — silently
// scanning zero files and emitting only the preflight reset, no utility
// classes. Rewriting them to absolute paths anchored to this file removes
// cwd from the equation entirely.
const here = path.dirname(fileURLToPath(import.meta.url))

export default {
  plugins: {
    tailwindcss: {
      ...tailwindConfig,
      content: tailwindConfig.content.map((glob) => path.resolve(here, glob)),
    },
    autoprefixer: {},
  },
}
