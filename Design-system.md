# Technical Design Specification: Autolyse (Artisan Hearth)

This document outlines the visual, structural, and SwiftUI implementation requirements for the Autolyse baking assistant.

## 1. Core Design Philosophy: "The Digital Boulangerie"
The application should feel like a premium, handcrafted artisan ledger. It prioritizes warmth, tactile feedback, and high-quality typography over a purely functional grid.

## 2. Global Theme (SwiftUI Constants)

### Colors (Asset Catalog or Extension)
- **Primary/Brand**: `Color(hex: "#A13923")` (Terracotta)
- **Secondary/Surface**: `Color(hex: "#FCF9F8")` (Warm Cream)
- **Text (Primary)**: `Color(hex: "#1B1C1C")` (Deep Charcoal)
- **Text (Secondary)**: `Color(hex: "#78716C")` (Stone-500)
- **Accent (Success)**: `Color(hex: "#D97706")` (Amber-600)

### Typography
- **Headings**: `Font.custom("NotoSerif-Bold", size: 34)` or `Font.custom("NotoSerif-Black", size: 28)`
- **Body/UI**: `Font.system(.body, design: .rounded)` or `SF Pro`

### Surface & Shape
- **Corner Radius**: `32` for primary cards, `24` for secondary elements.
- **Shadows**: `shadow(color: Color.black.opacity(0.06), radius: 32, x: 0, y: -4)` for the bottom bar.

## 3. SwiftUI Implementation Details

### View Modifiers & Styles
```swift
// Custom Button Style for the "Artisan" look
struct ArtisanButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 16)
            .padding(.horizontal, 32)
            .background(Color("BrandTerracotta"))
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
    }
}

// Glassmorphism for Top/Bottom Bars
extension View {
    func artisanGlass() -> some View {
        self.background(.ultraThinMaterial)
            .background(Color("WarmCream").opacity(0.8))
    }
}
```

### Shared Components

#### TopAppBar
- **Implementation**: `ToolbarItem` or a custom overlay view.
- **Style**: Use `artisanGlass()` modifier. Title in `Noto Serif Bold`.

#### BottomNavBar
- **Implementation**: Custom `HStack` within a `ZStack` (alignment: .bottom).
- **Geometry**: `rounded-t-[3rem]` achieved with a custom `UnevenRoundedRectangle`.
- **Interaction**: Active icons wrapped in a `Circle()` with low-opacity terracotta background.

#### Data Card
- **Implementation**: `VStack` with `background(Color("WarmCream"))` and `cornerRadius(32)`.

## 4. Key Screen Architectures

### Recipe Detail (Dough Calculator)
- **Hero Image**: `AsyncImage` with `aspectRatio(contentMode: .fill)` and `clipped()`.
- **Scaling Controls**: Custom `Stepper` using `HStack` with `Button` elements for a more tactile feel than the system default.

### Baking Guide
- **Step Card**: A `Tabview` with `.tabViewStyle(.page(indexDisplayMode: .never))` for horizontal swiping between steps.
- **Inline Timer**: A dedicated `TimerView` component with a circular progress bar (`ZStack` with `Circle`).

### Bake Journal
- **List Layout**: `ScrollView` with `LazyVStack` to handle large numbers of entries efficiently.
- **FAB**: A `Button` placed in an `overlay(alignment: .bottomTrailing)` with a `.shadow(radius: 10, y: 5)`.

## 5. State Management & Navigation
- **Navigation**: `NavigationStack` for hierarchical drill-downs (Recipes -> Detail -> Edit).
- **Data Flow**: `@StateObject` for the active baking session to persist timers even when navigating away.
- **Storage**: `SwiftData` or `CoreData` for recipe and journal persistence.
