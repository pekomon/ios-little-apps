# Weatherly

Weatherly is a SwiftUI weather app focused on fast local forecasts, city search, favorites, and a clean day-to-day experience.

It is built as a showcase-quality iOS project with a feature-first structure, modern Apple frameworks, and practical product polish.

## What The App Does

- Shows current weather and short-term forecast for your current location
- Lets you search cities and open detailed weather for each result
- Supports saving and managing favorite locations
- Includes app-level settings for units and appearance
- Provides a home screen widget for quick weather glance

## Key Features

- Home: current conditions, hourly forecast, daily forecast, weather metrics
- Search: location lookup with recent searches and city detail sheet
- Favorites: saved locations list with quick open and remove actions
- Settings: temperature/wind units, appearance preference, location permission status
- Widget: Weatherly widget powered by shared snapshot data

## Tech Stack

- Swift
- SwiftUI
- Observation (`@Observable`)
- WeatherKit
- CoreLocation
- MapKit (search/autocomplete)
- WidgetKit
- UserDefaults (lightweight persistence for settings/favorites/recent searches)

## Architecture

Feature-first app code with clear module boundaries:

- `App/`: app entry and root navigation
- `Features/`: Home, Search, Favorites, Settings
- `Domain/`: entities and repository protocols
- `Data/`: repository implementations, mappers, service integrations
- `Core/`: shared UI, formatting, location, widget helpers
- `Shared/`: widget snapshot models/stores shared between app and widget target

This keeps UI logic close to each feature while preserving clean boundaries for data and domain concerns.

## Notable iOS Integrations

- WeatherKit-backed weather fetching
- WidgetKit extension for glanceable weather
- CoreLocation permission flow for local weather
- MapKit-powered city search
- URL deep link support (`weatherly://home`)

## Screenshots

Screenshots can be added under `Weatherly/docs/screenshots/` and linked here.

- `[TODO] Home`
- `[TODO] Search`
- `[TODO] Favorites`
- `[TODO] Settings`
- `[TODO] Widget`

## Technical Highlights

- Feature polish pass with accessibility improvements on key screens
- Restrained haptic feedback on high-value interactions
- Native launch screen and app icon asset pipeline prepared for final artwork
- Maintainable app/widget data handoff through shared snapshot models
