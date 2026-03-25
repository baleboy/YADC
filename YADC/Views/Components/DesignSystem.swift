//
//  DesignSystem.swift
//  YADC
//
//  Design tokens and reusable modifiers for the Autolyse design system.
//

import SwiftUI

// MARK: - Typography

enum AppFont {
    static func serifHeadline(_ size: CGFloat) -> Font {
        .custom("NotoSerif-Bold", size: size)
    }

    static func serifDisplay(_ size: CGFloat) -> Font {
        .custom("NotoSerif-Black", size: size)
    }

    static func serifItalic(_ size: CGFloat) -> Font {
        // Fallback to system serif italic since we don't bundle NotoSerif-Italic
        .system(size: size, design: .serif).italic()
    }

    // Design system sans-serif fonts (Outfit in design, system rounded as fallback)
    static func heading(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    static func caption(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

// MARK: - Corner Radius

enum AppCornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let `default`: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let navBar: CGFloat = 48
    static let full: CGFloat = 9999
}

// MARK: - View Modifiers

struct ArtisanGlassModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .background(Color("CreamBackground").opacity(0.8))
    }
}

struct ArtisanCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color("SurfaceContainerLowest"))
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.default))
            .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 2)
    }
}

struct SectionLabelStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 11, weight: .semibold))
            .tracking(1.5)
            .textCase(.uppercase)
            .foregroundStyle(Color("TextSecondary"))
    }
}

struct GradientPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [Color("AccentColor"), Color("AccentColor").opacity(0.85)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 100))
            .shadow(color: Color("AccentColor").opacity(0.2), radius: 16, x: 0, y: 8)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}

struct ArtisanSegmentedPicker<SelectionValue: Hashable & CustomStringConvertible>: View {
    let options: [SelectionValue]
    @Binding var selection: SelectionValue

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { option in
                Button {
                    withAnimation(.spring(duration: 0.3)) {
                        selection = option
                    }
                } label: {
                    Text(option.description)
                        .font(.system(size: 14, weight: selection == option ? .semibold : .medium))
                        .foregroundStyle(selection == option ? Color("AccentColor") : Color("TextSecondary"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            selection == option
                                ? Color("SurfaceContainerLowest")
                                : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xl))
                        .shadow(color: selection == option ? Color.black.opacity(0.06) : .clear, radius: 4, y: 2)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color("SecondaryContainer"))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xl))
    }
}

// MARK: - View Extensions

extension View {
    func artisanGlass() -> some View {
        modifier(ArtisanGlassModifier())
    }

    func artisanCard() -> some View {
        modifier(ArtisanCardModifier())
    }

    func sectionLabel() -> some View {
        modifier(SectionLabelStyle())
    }
}
