# Project Overview

LockBox is a showcase-quality iOS app built with SwiftUI. It is a privacy-first local vault focused on secure local storage, biometric unlock, intentional UX, and a lightweight feature-first architecture with no third-party dependencies.

# Architecture Decisions

- Platform: iOS with SwiftUI app lifecycle.
- App code should prefer `@Observable` where state ownership is needed.
- Structure follows a feature-first layout with shared core security services and storage separated from domain entities.
- Security work should rely on platform primitives first: `LocalAuthentication` for biometrics and Keychain for secret storage.
- Metadata and secrets can be separated once local persistence is introduced.

# Current Status

- Existing project state: root app shell is in place and the domain layer now has initial vault entities.
- Build status: task 3 verified with `xcodebuild -project LockBox/LockBox.xcodeproj -scheme LockBox -destination 'generic/platform=iOS Simulator' build`.
- Active phase: Phase 1 - Foundation.
- Active task: 4. Add vault repository protocol.

# Phase Plan

1. Foundation
   - [x] 1. Add project folder structure
   - [x] 2. Add root app shell
   - [x] 3. Add vault domain models
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

- Task title: Add vault domain models
- Goal: Define the core vault entity types under `Domain` so later repository, storage, and feature work can depend on stable app-level models.
- Files expected to change:
  - `LockBox/PROJECT_PLAN.md`
  - replacement files under `LockBox/LockBox/Domain/Entities`
- Risks / notes:
  - Keep models independent from storage or platform security APIs.
  - Keep the model set small and flexible enough for notes, credentials, and other vault item types.
- Outcome after completion:
  - Added the first domain entity set for vault entries, metadata, and structured fields.
  - Kept the types storage-agnostic so repository and persistence work can adopt them unchanged.
  - Verified the app builds successfully for iOS Simulator.
- Commit message used: `Add LockBox vault domain models`

# Completed Tasks

- Task title: Add vault domain models
- Goal: Define the core vault entity types under `Domain` so later repository, storage, and feature work can depend on stable app-level models.
- Files changed:
  - `LockBox/PROJECT_PLAN.md`
  - `LockBox/LockBox/Domain/Entities/VaultEntry.swift`
  - `LockBox/LockBox/Domain/Entities/VaultEntryField.swift`
  - `LockBox/LockBox/Domain/Entities/VaultEntryMetadata.swift`
  - removed `LockBox/LockBox/Domain/Entities/EntitiesFolderMarker.swift`
- Risks / notes:
  - The current field model is intentionally general and may gain more specialized cases once editor and persistence requirements are clearer.
- Outcome after completion:
  - Added a `VaultEntry` aggregate with separate metadata, notes, and structured fields.
  - Added domain enums for entry kinds and field kinds, including sensitivity metadata for later UI decisions.
  - Verified the app builds successfully for iOS Simulator.
- Commit message used: `Add LockBox vault domain models`

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

- 4. Add vault repository protocol

# Open Questions / Follow-ups

- None currently. Folder marker files should be removed as real implementation files replace them in later tasks.
