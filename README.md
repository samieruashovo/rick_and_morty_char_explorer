# Rick and Morty Character Explorer

Flutter assessment implementation using Riverpod for state management and Hive for local persistence.

## Features

- Paginated character list with infinite scroll
- Character details screen
- Favorites with local persistence
- Local character edits that override API data in list and detail views
- Offline-first behavior by falling back to cached API data
- Search over loaded items and basic status filtering
- Reset edited character back to API values

## Tech Choices

- Riverpod: keeps async UI state, favorites, and local overrides predictable without heavy boilerplate
- Hive: lightweight local storage for cached pages, cached character records, favorites, and local edit overrides
- HTTP: direct integration with the Rick and Morty API

## Storage Approach

The app keeps separate data layers in Hive:

- `character_pages`: cached page metadata and character ids per page
- `characters`: cached base API character payloads
- `favorites`: persisted favorite ids
- `character_overrides`: local field-level edits made by the user

At runtime the UI merges `characters` with `character_overrides`, so local edits always win while the original API payload remains intact.

## Setup

1. Ensure Flutter stable is installed.
2. Run `flutter pub get`.
3. Run `flutter run`.

## Known Limitations

- Search and filters work on the pages already loaded into the app session.
- If a favorite character has never been fetched before and the device is offline, its details cannot be recovered until that character has been cached once.

## Validation

Run:

```bash
flutter analyze
flutter test
```
