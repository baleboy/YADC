//
//  ThemedComponents.swift
//  YADC
//
//  Custom themed components for the Autolyse design system.
//

import SwiftUI

// MARK: - View Modifiers

struct ThemedFormRowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowBackground(Color("FormRowBackground"))
    }
}

extension View {
    func themedFormRow() -> some View {
        modifier(ThemedFormRowModifier())
    }

    func themedTextField() -> some View {
        self
            .padding(12)
            .background(Color("SurfaceContainerHigh"))
            .foregroundStyle(Color("TextPrimary"))
            .tint(Color("AccentColor"))
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
    }
}

// MARK: - Custom Stepper

struct ThemedStepper: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int

    init(
        _ title: String,
        value: Binding<Int>,
        in range: ClosedRange<Int>,
        step: Int = 1
    ) {
        self.title = title
        self._value = value
        self.range = range
        self.step = step
    }

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(Color("TextPrimary"))

            Spacer()

            HStack(spacing: 12) {
                Button {
                    if value > range.lowerBound {
                        value = max(range.lowerBound, value - step)
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 36, height: 36)
                        .foregroundStyle(Color("TextPrimary"))
                        .background(Color("SecondaryContainer"))
                        .clipShape(Circle())
                }

                Text("\(value)")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color("TextPrimary"))
                    .frame(minWidth: 28)

                Button {
                    if value < range.upperBound {
                        value = min(range.upperBound, value + step)
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 36, height: 36)
                        .foregroundStyle(.white)
                        .background(Color("AccentColor"))
                        .clipShape(Circle())
                }
            }
        }
    }
}
