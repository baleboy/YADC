# YADC - Yet Another Dough Calculator

A SwiftUI iOS app for amateur bakers to calculate dough ingredients for pizza, bread, and other baked goods.

## Features

### Calculator Modes
- **Forward mode**: Enter hydration, number of dough balls, weight per ball, and ingredient percentages to calculate ingredient weights
- **Reverse mode**: Enter ingredient weights to calculate hydration percentage (unique feature among similar apps)

### Recipe Steps
- Add step-by-step instructions to your recipe
- Optional waiting time and temperature for each step
- Built-in timer with pause/resume functionality
- Background notifications when timers complete

### Additional Features
- Pre-ferment support (poolish, biga)
- Metric and imperial unit support
- Automatic recipe persistence
- Clean, native iOS interface

## Requirements

- iOS 26.1+
- Xcode 16+

## Building

```bash
# Build (Debug)
xcodebuild -scheme YADC -configuration Debug

# Build (Release)
xcodebuild -scheme YADC -configuration Release

# Run tests
xcodebuild test -scheme YADC
```

## Architecture

- **Framework**: SwiftUI with MVVM pattern
- **Persistence**: UserDefaults
- **Dependencies**: None (pure SwiftUI)

## Project Structure

```
YADC/
├── Models/
│   ├── Recipe.swift
│   ├── Ingredient.swift
│   ├── Step.swift
│   ├── PreFerment.swift
│   └── Settings.swift
├── ViewModels/
│   └── RecipeViewModel.swift
├── Views/
│   ├── Calculator/
│   ├── Steps/
│   ├── Recipe/
│   └── Settings/
├── Services/
│   ├── CalculationEngine.swift
│   ├── PersistenceService.swift
│   └── TimerService.swift
└── Extensions/
```

## License

This project is licensed under the MIT License - Non-Commercial. See [LICENSE](LICENSE) for details.

Free for personal and non-commercial use. For commercial licensing, please contact the author.
