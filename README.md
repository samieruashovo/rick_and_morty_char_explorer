# Rick and Morty Character Explorer

A Flutter assessment project that consumes the Rick and Morty API and demonstrates pagination, local persistence, offline-first behavior, favorites, and local editable character overrides.

Repository: `https://github.com/samieruashovo/rick_and_morty_char_explorer.git`

## Overview

This app fetches characters from the Rick and Morty API, caches them locally, and allows users to:

- browse characters with infinite scroll pagination
- view full character details
- add and remove favorites
- edit character fields locally without writing back to the API
- reset edited characters back to API data
- continue using cached content, favorites, and local edits while offline

## Tech Stack

- Flutter `3.41.1`
- Dart `3.11.0`
- Riverpod for state management
- Hive for local persistence
- HTTP for API requests

## Features

- Paginated character list
- Infinite scrolling
- Character details screen
- Favorites screen with local persistence
- Local editing for:
  - name
  - status
  - species
  - type
  - gender
  - origin name
  - location name
- Edited values override API data in both list and detail screens
- Reset to API data for locally edited characters
- Offline fallback to cached API data
- Search over loaded characters
- Basic status filtering
- Loading, empty, and error states
- Unit and widget tests for override/reset behavior

## Project Structure

```text
lib/
  core/
  features/characters/
    data/
    domain/
    presentation/
      controllers/
      screens/
      widgets/
test/
```

## State Management Choice

Riverpod was used because it keeps async and local UI state explicit and predictable with minimal boilerplate. It also makes it straightforward to separate:

- remote and cached data access
- favorites state
- local override state
- screen-level async loading flows

## Storage Approach

Hive is used as a lightweight local database. The app stores different concerns separately:

- `character_pages`
  - page metadata and character ids for paginated caching
- `characters`
  - cached base character data from the API
- `favorites`
  - favorite character ids
- `character_overrides`
  - locally edited field values

The runtime model is:

1. Load base character data from API or local cache.
2. Load local overrides from Hive.
3. Merge them in memory before rendering.

This ensures API data remains intact while user edits always take precedence in the UI.

## Offline-First Behavior

When the network is available, the app fetches characters from the API and updates the local cache.

When the network is unavailable, the app:

- shows cached character pages if available
- keeps favorites available locally
- keeps local character edits available locally

## Setup Guide

### Requirements

- Flutter `3.41.1`
- Dart `3.11.0`
- Android Studio or VS Code with Flutter and Dart plugins
- An emulator, simulator, or physical device

### 1. Clone the Repository

```bash
git clone https://github.com/samieruashovo/rick_and_morty_char_explorer.git
cd rick_and_morty_char_explorer
```

### 2. Verify Flutter Installation

```bash
flutter --version
flutter doctor
```

Expected versions:

- Flutter `3.41.1`
- Dart `3.11.0`

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run the App

```bash
flutter run
```

If multiple devices are connected:

```bash
flutter devices
flutter run -d <device_id>
```

### 5. Run Tests

```bash
flutter test
```

### 6. Analyze the Project

```bash
flutter analyze
```

### 7. Build APK

```bash
flutter build apk
```

Release output:

`build/app/outputs/flutter-apk/app-release.apk`

## API

Source API:

`https://rickandmortyapi.com/api/character`

The API is read-only, so all edits are handled locally and never sent back to the server.

## Testing

The test suite currently covers:

- character override merge behavior
- reset logic for removing local edits
- widget behavior for showing and hiding the `Reset to API data` action

## Known Limitations

- Search and filter currently work on the characters that have already been loaded in the current session.
- If a character has never been cached before and the device is offline, that character cannot be fetched until network access is restored.
- No generated Hive adapters are used; simple map-based persistence is used to keep the implementation lightweight.

## Submission Notes

This project was built to satisfy the assessment requirements with emphasis on:

- correctness
- clarity
- separation of concerns
- practical offline behavior

## Video Walkthrough

Add your YouTube walkthrough link here:

`https://youtu.be/GR2MM5sKFng`
