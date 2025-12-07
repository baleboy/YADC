# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

YADC (Yet Another Dough Calculator) is a SwiftUI iOS app for amateur bakers. It calculates dough ingredients in two modes:
1. **Forward mode**: Enter hydration, dough ball count/weight, ingredient percentages → get ingredient weights
2. **Reverse mode**: Enter ingredient weights → calculate hydration (unique feature among App Store competitors)

The MVP focuses on a single-recipe calculator with UserDefaults persistence. Pre-ferment support and multi-recipe management are planned.

## Build Commands

```bash
# Build (Debug)
xcodebuild -scheme YADC -configuration Debug

# Build (Release)
xcodebuild -scheme YADC -configuration Release

# Run all tests
xcodebuild test -scheme YADC

# Run unit tests only
xcodebuild -scheme YADC -only-testing:YADCTests test

# Run UI tests only
xcodebuild -scheme YADC -only-testing:YADCUITests test
```

## Architecture

- **Framework**: SwiftUI with MVVM pattern
- **Entry point**: `YADC/YADCApp.swift`
- **Main view**: `YADC/ContentView.swift`
- **Unit tests**: `YADCTests/` (Swift Testing framework)
- **UI tests**: `YADCUITests/` (XCTest framework)
- **Persistence**: UserDefaults (single recipe for MVP)
- **Dependencies**: None (pure SwiftUI, no SPM packages)
- **Target**: iOS 26.1+
