# Phase 2: Security Hardening - Checklist

> **Status:** Completed
> **Progress:** 3/3 milestones complete
> **Last Updated:** 2025-12-27

---

## Milestones

### 2.1 Firebase App Check Production Setup
- [x] Create AppConfig class (lib/core/config/app_config.dart)
- [x] Update App Check initialization with environment-based providers
- [x] Debug mode uses AndroidDebugProvider / AppleDebugProvider
- [x] Release mode uses AndroidPlayIntegrityProvider / AppleDeviceCheckProvider
- [x] flutter analyze passes
- **Status:** Done
- **Note:** Play Integrity (Android) and Device Check (iOS) require Firebase Console configuration by the app owner

### 2.2 Secure PDF Generation
- [x] Use private app directory (getApplicationDocumentsDirectory/reports)
- [x] Sanitize child names in filenames (_sanitizeFileName method)
- [x] Add cleanup for old reports (_cleanupOldReports - 24h expiry)
- [x] Added context.mounted checks for async operations
- [x] flutter analyze passes
- **Status:** Done

### 2.3 Firestore Security Rules
- [x] Create firestore.rules file with comprehensive security rules
- [ ] Deploy security rules (requires Firebase CLI: `firebase deploy --only firestore:rules`)
- [x] Add isDeleted/updatedAt fields to Child model for soft delete support
- [x] Add copyWithDeleted() method for soft delete operations
- [x] Update HomeScreen query to filter out soft-deleted children
- [x] flutter analyze passes
- **Status:** Done (deployment pending)

---

## Verification

When all milestones complete:
- [x] App Check configured for debug and release modes
- [x] PDFs stored in private directory
- [ ] Security rules deployed (run: firebase deploy --only firestore:rules)
- [ ] App Check enforced in Firebase Console (optional, after testing)
- [x] All existing functionality works

---

## Notes

### Session 11 (2.1 Firebase App Check):
- Created AppConfig class with isDebug, isProduction, isProfile getters
- Updated main.dart to use environment-based providers:
  - Debug: AndroidDebugProvider(), AppleDebugProvider()
  - Release: AndroidPlayIntegrityProvider(), AppleDeviceCheckProvider()
- Firebase Console configuration (Play Integrity API, Device Check) is app-owner responsibility

### Firebase Console Setup Required (for production):
1. **Android (Play Integrity)**:
   - Go to Firebase Console > App Check
   - Click Android app > Select "Play Integrity"
   - Add SHA-256 certificate fingerprint
   - Enable Play Integrity API in Google Cloud Console

2. **iOS (Device Check)**:
   - Go to Firebase Console > App Check
   - Click iOS app > Select "DeviceCheck"
   - Enter Team ID from Apple Developer Portal
