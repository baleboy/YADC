//
//  ThemedComponents.swift
//  YADC
//
//  Custom themed components for reliable color application
//

import SwiftUI

// MARK: - View Modifiers

struct ThemedFormRowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowBackground(Color("FormRowBackground"))
    }
}

struct ThemedTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(8)
            .background(Color("FormRowBackground"))
            .foregroundStyle(Color("TextPrimary"))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color("TextTertiary"), lineWidth: 1)
            )
    }
}

extension View {
    func themedFormRow() -> some View {
        modifier(ThemedFormRowModifier())
    }

    func themedTextField() -> some View {
        self
            .padding(8)
            .background(Color("FormRowBackground"))
            .foregroundStyle(Color("TextPrimary"))
            .tint(Color("AccentColor"))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color("TextTertiary"), lineWidth: 1)
            )
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

            HStack(spacing: 0) {
                Button {
                    if value > range.lowerBound {
                        value = max(range.lowerBound, value - step)
                    }
                } label: {
                    Image(systemName: "minus")
                        .frame(width: 44, height: 32)
                        .foregroundStyle(Color("TextPrimary"))
                        .background(Color("FormRowBackground"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("TextTertiary"), lineWidth: 1)
                        )
                }

                Button {
                    if value < range.upperBound {
                        value = min(range.upperBound, value + step)
                    }
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 44, height: 32)
                        .foregroundStyle(Color("TextPrimary"))
                        .background(Color("FormRowBackground"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("TextTertiary"), lineWidth: 1)
                        )
                }
            }
        }
    }
}
