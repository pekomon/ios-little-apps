# Project Overview

LockBox is a showcase-quality iOS app built with SwiftUI. It is a privacy-first local vault focused on secure local storage, biometric unlock, intentional UX, and a lightweight feature-first architecture with no third-party dependencies.

# Architecture Decisions

- Platform: iOS with SwiftUI app lifecycle.
- App code should prefer `@Observable` where state ownership is needed.
- Structure follows a feature-first layout with shared core security services and storage separated from domain entities.
- Security work should rely on platform primitives first: `LocalAuthentication` for biometrics and Keychain for secret storage.
- Metadata and secrets can be separated once local persistence is introduced.

# Current Status

- Existing project state: the app unlocks into a polished local vault experience that now has stronger VoiceOver grouping, labels, and hints across the lock, list, detail, and editor flows.
- Build status: task 17 verified with `xcodebuild -project LockBox/LockBox.xcodeproj -scheme LockBox -destination 'generic/platform=iOS Simulator' build`.
- Active phase: Phase 1 - Foundation.
- Active task: 18. Add haptic feedback.

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
   - [x] 9. Add default vault repository
   - [x] 10. Add local vault persistence
4. Vault UX
   - [x] 11. Add vault list feature
   - [x] 12. Add entry editor feature
   - [x] 13. Add entry detail feature
   - [x] 14. Add delete/edit flows
5. Product polish
   - [x] 15. Add app relock on background
   - [x] 16. Polish vault UI
   - [x] 17. Improve accessibility support
   - [ ] 18. Add haptic feedback
   - [ ] 19. Improve README / showcase presentation

# Current Task

- Task title: Improve accessibility support
- Goal: Strengthen accessibility semantics across the app so VoiceOver users can understand structure, actions, and sensitive content more reliably.
- Files expected to change:
  - `LockBox/PROJECT_PLAN.md`
  - `LockBox/LockBox/Features/VaultList/VaultListView.swift`
  - `LockBox/LockBox/Features/EntryDetail/EntryDetailView.swift`
  - `LockBox/LockBox/Features/EntryEditor/EntryEditorView.swift`
  - `LockBox/LockBox/Features/Lock/LockScreenView.swift`
- Risks / notes:
  - Improve screen-reader behavior without flattening the visual hierarchy or changing working CRUD and lock behavior.
  - Decorative elements should be hidden from accessibility where they add noise rather than meaning.
- Outcome after completion:
  - Added clearer VoiceOver grouping, labels, values, and hints across the vault list, detail, editor, and lock flows.
  - Reduced decorative accessibility noise by hiding non-informational glyphs and dividers.
  - Improved screen-reader summaries for entry cards and sensitive-field presentation.
  - Verified the app builds successfully for iOS Simulator.
- Commit message used: `Improve LockBox accessibility support`

# Completed Tasks

- Task title: Improve accessibility support
- Goal: Strengthen accessibility semantics across the app so VoiceOver users can understand structure, actions, and sensitive content more reliably.
- Files changed:
  - `LockBox/PROJECT_PLAN.md`
  - `LockBox/LockBox/Features/VaultList/VaultListView.swift`
  - `LockBox/LockBox/Features/EntryDetail/EntryDetailView.swift`
  - `LockBox/LockBox/Features/EntryEditor/EntryEditorView.swift`
  - `LockBox/LockBox/Features/Lock/LockScreenView.swift`
- Risks / notes:
  - This pass focuses on semantics and hints; larger dynamic-type layout validation can still be refined later if needed.
  - Sensitive values remain available in the detail screen by design, but screen-reader cues now identify those fields explicitly.
- Outcome after completion:
  - Improved VoiceOver grouping and action hints across the main app flows.
  - Added stronger accessibility summaries for list cards and form fields.
  - Reduced decorative accessibility noise in the lock and detail presentations.
  - Verified the app builds successfully for iOS Simulator.
- Commit message used: `Improve LockBox accessibility support`

- Task title: Polish vault UI
- Goal: Improve the visual hierarchy and readability of the unlocked vault flows so list, detail, and editor screens feel cohesive and intentional.
- Files changed:
  - `LockBox/PROJECT_PLAN.md`
  - `LockBox/LockBox/Features/VaultList/VaultListView.swift`
  - `LockBox/LockBox/Features/EntryDetail/EntryDetailView.swift`
  - `LockBox/LockBox/Features/EntryEditor/EntryEditorView.swift`
- Risks / notes:
  - This pass stays presentational; accessibility semantics and haptics still belong to later dedicated tasks.
  - Sensitive fields remain visible in detail view by design; this task focuses on readability rather than reveal controls.
- Outcome after completion:
  - Refined the list, detail, and editor surfaces into a more cohesive vault experience.
  - Improved date, truncation, iconography, and empty-state treatment in the list.
  - Improved hierarchy and field readability in the detail and editor flows.
  - Verified the app builds successfully for iOS Simulator.
- Commit message used: `Polish LockBox vault UI`

- Task title: Add app relock on background
- Goal: Relock the vault automatically when the app backgrounds so unlocked content is protected when the user leaves the app.
- Files changed:
  - `LockBox/PROJECT_PLAN.md`
  - `LockBox/LockBox/App/LockBoxRootView.swift`
  - `LockBox/LockBox/Core/Security/AppLockManager.swift`
- Risks / notes:
  - The app currently relocks on background only; finer-grained policies such as timeouts or screenshot hardening can be layered later if needed.
  - Temporary inactive states are intentionally ignored to avoid interfering with biometric prompts and system overlays.
- Outcome after completion:
  - Added automatic relock when the app backgrounds.
  - Refreshed biometric availability on return to the active scene.
  - Preserved the existing launch and unlock flows while extending protection to lifecycle transitions.
  - Verified the app builds successfully for iOS Simulator.
- Commit message used: `Add LockBox app relock on background`

- Task title: 14.1 Small layout cleanup
- Goal: Tighten the unlocked vault screen layout after task-14 review feedback so the header, primary action, and footer feel intentional on device.
- Files changed:
  - `LockBox/PROJECT_PLAN.md`
  - `LockBox/LockBox/App/LockBoxRootView.swift`
  - `LockBox/LockBox/Features/VaultList/VaultListView.swift`
- Risks / notes:
  - This follow-up stays presentational only and should not be treated as part of lifecycle relock work.
- Outcome after completion:
  - Moved the primary `New` action into the navigation bar.
  - Reworked the vault header into a compact visible surface and reduced excess top whitespace.
  - Slimmed the footer bar so it supports the content instead of competing with it.
  - Verified the app builds successfully for iOS Simulator.
- Commit message used: `Refine LockBox vault list layout`

- Task title: Add delete/edit flows
- Goal: Allow editing and deleting existing vault entries while keeping detail, list, and local persistence in sync after each mutation.
- Files changed:
  - `LockBox/PROJECT_PLAN.md`
  - `LockBox/LockBox/Features/EntryDetail/EntryDetailView.swift`
  - `LockBox/LockBox/Features/EntryEditor/EntryEditorView.swift`
  - `LockBox/LockBox/Features/EntryEditor/EntryEditorViewModel.swift`
  - `LockBox/LockBox/Features/VaultList/VaultListView.swift`
  - `LockBox/LockBox/Features/VaultList/VaultListViewModel.swift`
- Risks / notes:
  - The detail screen now owns edit/delete actions directly; a later polish pass may refine affordances or add field-level reveal controls.
  - Sample entries are now seeded only on the first load path so user-driven empty states stay empty after deletions.
- Outcome after completion:
  - Added edit and delete actions to the entry detail screen.
  - Reused the existing editor to update entries while preserving IDs and original creation timestamps.
  - Kept the list and persistence layer in sync after updates and deletions.
  - Verified the app builds successfully for iOS Simulator.
- Commit message used: `Add LockBox delete and edit flows`

- Task title: Add entry detail feature
- Goal: Add a read-only detail screen for vault entries so users can open an item from the list and inspect all stored fields and notes.
- Files changed:
  - `LockBox/PROJECT_PLAN.md`
  - `LockBox/LockBox/Features/EntryDetail/EntryDetailView.swift`
  - `LockBox/LockBox/Features/VaultList/VaultListView.swift`
  - removed `LockBox/LockBox/Features/EntryDetail/EntryDetailFeatureFolderMarker.swift`
- Risks / notes:
  - Sensitive values are visible in the detail view by design here; masking or reveal controls can be refined in later polish or edit flows.
- Outcome after completion:
  - Added a read-only detail screen for vault entries.
  - Wired list cards into navigation links so the vault now supports list -> detail flow.
  - Verified the app builds successfully for iOS Simulator.
- Commit message used: `Add LockBox entry detail feature`

- Task title: Add entry editor feature
- Goal: Add the first entry creation flow so new vault items can be saved from UI into the live repository and persistence stack.
- Files changed:
  - `LockBox/PROJECT_PLAN.md`
  - `LockBox/LockBox/Features/EntryEditor/EntryEditorView.swift`
  - `LockBox/LockBox/Features/EntryEditor/EntryEditorViewModel.swift`
  - `LockBox/LockBox/Features/VaultList/VaultListView.swift`
  - `LockBox/LockBox/Features/VaultList/VaultListViewModel.swift`
  - removed `LockBox/LockBox/Features/EntryEditor/EntryEditorFeatureFolderMarker.swift`
- Risks / notes:
  - The editor currently supports creation only; edit and detail presentation still belong to later tasks.
- Outcome after completion:
  - Added a sheet-based entry editor with entry kind, fields, notes, and tags.
  - Wired new entries into the live repository and refreshed the vault list after save.
  - Verified the app builds successfully for iOS Simulator.
- Commit message used: `Add LockBox entry editor feature`

- Task title: Add vault list feature
- Goal: Replace the unlocked placeholder shell with the first real vault screen backed by the live repository and local persistence stack.
- Files changed:
  - `LockBox/PROJECT_PLAN.md`
  - `LockBox/LockBox/App/LockBoxRootView.swift`
  - `LockBox/LockBox/Features/VaultList/VaultListView.swift`
  - `LockBox/LockBox/Features/VaultList/VaultListViewModel.swift`
  - removed `LockBox/LockBox/Features/VaultList/VaultListFeatureFolderMarker.swift`
- Risks / notes:
  - The feature currently seeds first-run sample entries for immediate usability; later tasks may replace or expand that onboarding behavior.
- Outcome after completion:
  - Added a real unlocked vault surface with entry counts, seeded entries, and redacted sensitive field values.
  - Wired the UI to the live repository and local persistence stack.
  - Verified the app builds successfully for iOS Simulator.
- Commit message used: `Add LockBox vault list feature`

- Task title: Add local vault persistence
- Goal: Add the concrete file-backed metadata persistence implementation so the default repository can run against real local storage.
- Files changed:
  - `LockBox/PROJECT_PLAN.md`
  - `LockBox/LockBox/Data/Storage/JSONFileVaultEntryMetadataStore.swift`
- Risks / notes:
  - Only entry metadata is stored in the JSON file; secret payloads remain delegated to the secure value store.
- Outcome after completion:
  - Added `JSONFileVaultEntryMetadataStore` as the live Foundation-based metadata persistence service.
  - Added `VaultPersistenceLocation` and local persistence error handling.
  - Verified the app builds successfully for iOS Simulator.
- Commit message used: `Add LockBox local vault persistence`

- Task title: Add default vault repository
- Goal: Add the main repository implementation that translates between domain entities and the lower-level metadata and secure-storage services.
- Files changed:
  - `LockBox/PROJECT_PLAN.md`
  - `LockBox/LockBox/Data/Repositories/DefaultVaultRepository.swift`
  - `LockBox/LockBox/Data/Models/VaultEntryRecord.swift`
  - `LockBox/LockBox/Data/Storage/VaultEntryMetadataStore.swift`
  - removed `LockBox/LockBox/Data/Repositories/DataRepositoriesFolderMarker.swift`
  - removed `LockBox/LockBox/Data/Models/ModelsFolderMarker.swift`
- Risks / notes:
  - The repository still depends on an abstract metadata store; the concrete local file implementation lands in the next task.
- Outcome after completion:
  - Added `DefaultVaultRepository` with async CRUD operations built on the metadata store and secure value store.
  - Added the record and payload types needed to persist entry metadata and secret content separately.
  - Verified the app builds successfully for iOS Simulator.
- Commit message used: `Add LockBox default vault repository`

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

- 18. Add haptic feedback

# Open Questions / Follow-ups

- None currently. Folder marker files should be removed as real implementation files replace them in later tasks.
