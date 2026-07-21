import { initializeApp, type FirebaseApp, type FirebaseOptions } from 'firebase/app'

const firebaseConfig: FirebaseOptions = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
  appId: import.meta.env.VITE_FIREBASE_APP_ID,
}

/** True only when the minimum fields required to initialize Firebase are present. */
export const isFirebaseConfigured = Boolean(
  firebaseConfig.apiKey && firebaseConfig.projectId && firebaseConfig.appId,
)

let initializedApp: FirebaseApp | null = null

if (isFirebaseConfigured) {
  try {
    initializedApp = initializeApp(firebaseConfig)
  } catch (error) {
    console.warn('[firebase] Initialization failed — continuing without Firebase.', error)
    initializedApp = null
  }
} else if (import.meta.env.DEV) {
  console.info(
    '[firebase] VITE_FIREBASE_* env vars are not set — Firebase-backed features are disabled. See .env.example.',
  )
}

/** The initialized Firebase app, or `null` when config is missing/invalid. Always null-check before use. */
export const firebaseApp: FirebaseApp | null = initializedApp
