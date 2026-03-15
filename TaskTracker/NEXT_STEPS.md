# TaskTracker TODO

## Priority 1: Correctness and Developer Experience

- [ ] Add `createdAt` to the task model.
- [ ] Sort the SwiftData query by `createdAt`.
- [ ] Keep task order stable across launches.
- [ ] Add a SwiftData model container to previews.
- [ ] Use an in-memory preview container with sample tasks.
- [ ] Decide whether the manual `id` property is needed or should be removed.
- [ ] Simplify the tap gesture handler in `ContentView`.

## Priority 2: Core UX Improvements

- [ ] Add filtering: `All`, `Active`, `Completed`.
- [ ] Add an empty state for no tasks.
- [ ] Support adding a task with keyboard Return via `onSubmit`.
- [ ] Keep text field focus ergonomic after adding a task.
- [ ] Make the whole task row tappable with `contentShape(Rectangle())`.
- [ ] Improve task row spacing and styling.
- [ ] Add a small summary: total tasks and completed tasks.
- [ ] Review whether `circlebadge` should be replaced with a clearer incomplete-task icon.
- [ ] Add accessibility labels/hints for task actions.

## Priority 3: Structural Cleanup

- [ ] Review whether explicit sorting options are still needed after `createdAt` sorting is added.
- [ ] Extract a `TaskRowView` if the row UI grows more complex.

## Priority 4: Tests

- [ ] Add unit tests for task creation.
- [ ] Add unit tests for empty-input and trimmed-input behavior.
- [ ] Add unit tests for completion toggle.
- [ ] Add unit tests for deletion.
- [ ] Add tests for ordering once `createdAt` is added.
- [ ] Add tests for filtering once filters exist.
- [ ] Add a preview/test fixture setup for sample tasks.

## Notes

- Avoid adding a view model until the screen has more state or derived logic.
- Filtering is the best next feature before introducing a view model.
