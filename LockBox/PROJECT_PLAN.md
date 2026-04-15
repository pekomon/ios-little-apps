# Project Overview

LockBox is a showcase-quality iOS app built with SwiftUI. It is a privacy-first local vault focused on secure local storage, biometric unlock, intentional UX, and a lightweight feature-first architecture with no third-party dependencies.

# Architecture Decisions

- Platform: iOS with SwiftUI app lifecycle.
- App code should prefer `@Observable` where state ownership is needed.
- Structure follows a feature-first layout with shared core security services and storage separated from domain entities.
- Security work should rely on platform primitives first: `LocalAuthentication` for biometrics and Keychain for secret storage.
- Metadata and secrets can be separated once local persistence is introduced.

# Current Status

- Existing project state: fresh SwiftUI template with `LockBoxApp.swift` and `ContentView.swift`.
- Build status: task 2 verified with `xcodebuild -project LockBox/LockBox.xcodeproj -scheme LockBox -destination 'generic/platform=iOS Simulator' build`.
- Active phase: Phase 1 - Foundation.
- Active task: 3. Add vault domain models.

# Phase Plan

1. Foundation
   - [x] 1. Add project folder structure
   - [x] 2. Add root app shell
   - [ ] 3. Add vault domain models
   - [ ] 4. Add vault repository protocol
2. Security core
   - [ ] 5. Add biometric auth service
   - [ ] 6. Add app lock manager
   - [ ] 7. Add lock screen flow
3. Local vault data
   - [ ] 8. Add secure storage services
   - [ ] 9. Add default vault repository
   - [ ] 10. Add local vault persistence
4. Vault UX
   - [ ] 11. Add vault list feature
   - [ ] 12. Add entry editor feature
   - [ ] 13. Add entry detail feature
   - [ ] 14. Add delete/edit flows
5. Product polish
   - [ ] 15. Add app relock on background
   - [ ] 16. Polish vault UI
   - [ ] 17. Improve accessibility support
   - [ ] 18. Add haptic feedback
   - [ ] 19. Improve README / showcase presentation

# Current Task

- Task title: Add root app shell
- Goal: Replace the template entry UI with a polished root shell under the `App` folder while keeping the app behavior simple and buildable.
- Files expected to change:
  - `LockBox/PROJECT_PLAN.md`
  - `LockBox/LockBox/LockBoxApp.swift`
  - `LockBox/LockBox/ContentView.swift` or replacement files under `LockBox/LockBox/App`
- Risks / notes:
  - Keep scope limited to the shell only; do not introduce vault data or security flows before their roadmap steps.
  - The app shell should establish a clean visual direction that can support the lock flow later.
- Outcome after completion:
  - Replaced the SwiftUI template entry screen with a polished root shell under `App`.
  - Wired the app entry point to the new shell without introducing domain, storage, or security behavior early.
  - Verified the app builds successfully for iOS Simulator.
- Commit message used: `Add LockBox root app shell`

# Completed Tasks

- Task title: Add root app shell
- Goal: Replace the template entry UI with a polished root shell under the `App` folder while keeping the app behavior simple and buildable.
- Files changed:
  - `LockBox/PROJECT_PLAN.md`
  - `LockBox/LockBox/LockBoxApp.swift`
  - `LockBox/LockBox/App/LockBoxRootView.swift`
  - removed `LockBox/LockBox/ContentView.swift`
  - removed `LockBox/LockBox/App/AppFolderMarker.swift`
- Risks / notes:
  - The root shell is intentionally static and should not be treated as the real lock or onboarding flow.
- Outcome after completion:
  - Added a vault-themed landing shell with a header, hero card, planned flow card, and footer status area.
  - Established the visual direction for later lock and setup work while keeping the app behavior simple.
  - Verified the app builds successfully for iOS Simulator.
- Commit message used: `Add LockBox root app shell`

- Task title: Add project folder structure
- Goal: Create the planned feature-first folder layout inside the LockBox target without changing product behavior yet.
- Files changed:
  - `LockBox/PROJECT_PLAN.md`
  - new folder marker files under `LockBox/LockBox/App`, `Core`, `Domain`, `Data`, `Features`, and `Resources`
- Risks / notes:
  - The file-system-synchronized Xcode target copied identical `.gitkeep` files as resources and caused duplicate output collisions.
  - Resolved by replacing `.gitkeep` files with unique folder marker filenames and a single resource placeholder file.
- Outcome after completion:
  - Added the planned project folder hierarchy inside the LockBox target.
  - Verified the app still builds successfully for iOS Simulator.
- Commit message used: `Add LockBox project structure`

# Next Recommended Task

- 3. Add vault domain models

# Open Questions / Follow-ups

- None currently. Folder marker files should be removed as real implementation files replace them in later tasks.
