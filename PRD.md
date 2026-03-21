# Autolyse

Autolyse is a dough calculator and baking companion for amateur bakers. It helps bakers create, manage, and execute dough recipes with precise ingredient calculations.

## Core Concept

Autolyse supports two calculation modes:

- **Forward mode**: Enter hydration %, number of dough balls, weight per ball, and ingredient percentages — get calculated ingredient weights.
- **Reverse mode**: Enter ingredient weights (e.g. from a cookbook recipe) — calculate hydration % and baker's percentages automatically.

The reverse mode is a unique differentiator among App Store dough calculators. Once a recipe is entered in either mode, it can be scaled up or down for different numbers of dough balls.

Users can switch between modes at any time, for example starting with ingredient weights from a book and then tweaking the hydration.

## Features

### Recipe Management

- Create, edit, and delete multiple recipes
- Recipe editor with four tabs: By Percentage (forward mode), By Weight (reverse mode), Steps, and Preview
- Hero images for recipes via camera or photo library
- Default "Pizza Dough" template for new users

### Pre-Ferment Support

- Built-in pre-ferment types: Poolish (100% hydration), Biga (55% hydration), and Custom
- Pre-ferments are broken down into their sub-ingredients (flour, water, yeast)
- Correct handling of pre-ferment flour/water in hydration calculations to avoid double-counting

### Baking Workflow

- Scale a recipe before baking by ball count (1–100) or multiplier (0.5x–3.0x)
- Step-by-step baking guide with progress tracking
- Active bake sessions persist across app restarts

### Timers & Notifications

- Optional timer on each recipe step (in minutes)
- Timer controls: play, pause, stop
- Local notifications when timers expire
- Deep linking from notification to the active bake session
- Multiple concurrent timers supported

### Bake Journal

- Save a journal entry after completing a bake
- 1–5 star rating per bake
- Free-form notes
- Up to 5 photos per entry (camera or photo library)
- Average rating and bake count shown on recipe detail

### Settings

- Unit system: metric (grams/°C) or imperial (ounces/°F)
- Dough residue percentage (0–10%): accounts for dough lost during handling, increases target dough weight accordingly
- Reset all data

## Navigation

The app uses a tab-based layout with three tabs:

1. **Recipes** — recipe list, recipe detail, recipe editor
2. **Bakes** — active bake sessions (in progress) and completed bakes (journal entries)
3. **Settings** — unit system, dough residue, reset

## Technical Details

- **Platform**: iOS 17.0+
- **Framework**: Pure SwiftUI, no external dependencies
- **Architecture**: MVVM with Observable view models and singleton services
- **Persistence**: UserDefaults (JSON-encoded models) with file-based image storage in Documents directory
- **Version**: 1.0.0