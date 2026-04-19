# Project Overview

LockBox is a showcase-quality iOS app built with SwiftUI. It is a privacy-first local vault focused on secure local storage, biometric unlock, intentional UX, and a lightweight feature-first architecture with no third-party dependencies.

# Architecture Decisions

- Platform: iOS with SwiftUI app lifecycle.
- App code should prefer `@Observable` where state ownership is needed.
- Structure follows a feature-first layout with shared core security services and storage separated from domain entities.
- Security work should rely on platform primitives first: `LocalAuthentication` for biometrics and Keychain for secret storage.
- Metadata and secrets can be separated once local persistence is introduced.

# Current Status

- Existing project state: the app now has a visible lock flow, a secure storage service, and the next step is wiring the default repository.
- Build status: task 8 verified with `xcodebuild -project LockBox/LockBox.xcodeproj -scheme LockBox -destination 'generic/platform=iOS Simulator' build`.
- Active phase: Phase 1 - Foundation.
- Active task: 9. Add default vault repository.

# Phase Plan

1. Foundation
   - [x] 1. Add project folder structure
   - [x] 2. Add root app shell
   - [x] 3. Add vault domain models
   - [x] 4. Add vault repository protocol
2. Security core
   - [x] 5. Add biometric auth service
   - [x] 6. Add app lock manager
   - [x] 7. Add lock screen flow
3. Local vault data
   - [x] 8. Add secure storage services
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

- Task title: Add secure storage services
- Goal: Add the secure low-level storage service that later persistence and repository code can use for secrets without exposing raw Keychain APIs across the app.
- Files expected to change:
  - `LockBox/PROJECT_PLAN.md`
  - files under `LockBox/LockBox/Data/Storage`
- Risks / notes:
  - Keep the service focused on raw secure value storage, not vault-specific repository concerns.
  - Favor a small wrapper around Keychain so future code is easy to stub or replace.
- Outcome after completion:
  - Added a small secure value storage abstraction and a live Keychain-backed implementation.
  - Wrapped common read, write, and delete flows without exposing Security APIs to higher layers.
  - Verified the app builds successfully for iOS Simulator.
- Commit message used: `Add LockBox secure storage services`

# Completed Tasks

- Task title: Add secure storage services
- Goal: Add the secure low-level storage service that later persistence and repository code can use for secrets without exposing raw Keychain APIs across the app.
- Files changed:
  - `LockBox/PROJECT_PLAN.md`
  - `LockBox/LockBox/Data/Storage/SecureValueStore.swift`
  - removed `LockBox/LockBox/Data/Storage/StorageFolderMarker.swift`
- Risks / notes:
  - The service intentionally stores raw `Data`; vault-specific encoding remains the responsibility of repository and persistence layers.
- Outcome after completion:
  - Added `SecureValueStoring` and `KeychainSecureValueStore`.
  - Added typed secure store keys and error mapping for common Keychain operations.
  - Verified the app builds successfully for iOS Simulator.
- Commit message used: `Add LockBox secure storage services`

- Task title: Add lock screen flow
- Goal: Connect the app lock manager to the shell so the app launches into a real lock screen and can transition into unlocked content through the biometric flow.
- Files changed:
  - `LockBox/PROJECT_PLAN.md`
  - `LockBox/LockBox/App/LockBoxRootView.swift`
  - `LockBox/LockBox/Features/Lock/LockScreenView.swift`
  - `LockBox/LockBox/Core/Security/BiometricAuthService.swift`
  - removed `LockBox/LockBox/Features/Lock/LockFeatureFolderMarker.swift`
- Risks / notes:
  - The lock flow currently focuses on launch-time unlock only; relocking on background and unlocked navigation belong to later tasks.
- Outcome after completion:
  - Added a simulator-visible lock screen with status, error, and biometric availability feedback.
  - Blurred and protected the shell content until unlock succeeds.
  - Verified the app builds successfully for iOS Simulator.
- Commit message used: `Add LockBox lock screen flow`

- Task title: Add app lock manager
- Goal: Add an observable lock-state owner that coordinates biometric availability and unlock attempts without introducing the actual lock screen UI yet.
- Files changed:
  - `LockBox/PROJECT_PLAN.md`
  - `LockBox/LockBox/Core/Security/AppLockManager.swift`
- Risks / notes:
  - The manager currently owns only in-memory lock state; background relock and scene lifecycle hooks still belong to later tasks.
- Outcome after completion:
  - Added `AppLockManager` as the observable coordinator for lock state and unlock attempts.
  - Kept biometric policy and error handling delegated to `BiometricAuthService`.
  - Verified the app builds successfully for iOS Simulator.
- Commit message used: `Add LockBox app lock manager`

- Task title: Add biometric auth service
- Goal: Define a reusable live biometric authentication service in `Core/Security` so later lock-state flows can ask for device biometrics without owning `LocalAuthentication` details directly.
- Files changed:
  - `LockBox/PROJECT_PLAN.md`
  - `LockBox/LockBox/Core/Security/BiometricAuthService.swift`
  - removed `LockBox/LockBox/Core/Security/SecurityFolderMarker.swift`
- Risks / notes:
  - The service currently exposes only the live implementation surface; preview or test doubles can be added later when lock-state logic starts depending on it.
- Outcome after completion:
  - Added `BiometricAuthService` with availability inspection and async authentication.
  - Added app-level biometric kind, availability, and error abstractions around `LAContext`.
  - Verified the app builds successfully for iOS Simulator.
- Commit message used: `Add LockBox biometric auth service`

- Task title: Add vault repository protocol
- Goal: Define the domain-level repository contract that future data implementations will satisfy without coupling the feature layer to storage details.
- Files changed:
  - `LockBox/PROJECT_PLAN.md`
  - `LockBox/LockBox/Domain/Repositories/VaultRepository.swift`
  - removed `LockBox/LockBox/Domain/Repositories/DomainRepositoriesFolderMarker.swift`
- Risks / notes:
  - The current protocol favors a small CRUD-oriented surface and may gain richer query capabilities later if feature work demands them.
- Outcome after completion:
  - Added the `VaultRepository` protocol with async CRUD-style entry operations.
  - Added `VaultRepositoryError` for domain-level not-found handling.
  - Verified the app builds successfully for iOS Simulator.
- Commit message used: `Add LockBox vault repository protocol`

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

- 9. Add default vault repository

# Open Questions / Follow-ups

- None currently. Folder marker files should be removed as real implementation files replace them in later tasks.
