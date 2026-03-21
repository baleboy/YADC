//
//  NewRecipeEntryModeView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 15.12.2025.
//

import SwiftUI

struct NewRecipeEntryModeView: View {
    @Environment(RecipeStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMode: CalculatorMode?

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                VStack(spacing: 8) {
                    Text("New Recipe")
                        .font(AppFont.serifHeadline(28))
                        .foregroundStyle(Color("TextPrimary"))
                    Text("How would you like to enter your recipe?")
                        .font(.subheadline)
                        .foregroundStyle(Color("TextSecondary"))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)

                VStack(spacing: 16) {
                    modeButton(
                        icon: "percent",
                        title: "By Percentage",
                        description: "Enter hydration and ingredient percentages, and the app calculates the weights for you.",
                        mode: .forward
                    )

                    modeButton(
                        icon: "scalemass",
                        title: "By Weight",
                        description: "Enter ingredient weights from a cookbook or existing recipe, and the app calculates the percentages.",
                        mode: .reverse
                    )
                }
                .padding(.horizontal)

                Spacer()
            }
            .background(Color("CreamBackground"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color("TextSecondary"))
                }
            }
            .fullScreenCover(item: $selectedMode, onDismiss: {
                dismiss()
            }) { mode in
                RecipeEditorView(recipe: nil, initialMode: mode)
                    .environment(store)
            }
        }
    }

    private func modeButton(icon: String, title: String, description: String, mode: CalculatorMode) -> some View {
        Button {
            selectedMode = mode
        } label: {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(Color("AccentColor"))
                    .frame(width: 48, height: 48)
                    .background(Color("AccentColor").opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color("TextPrimary"))
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(Color("TextSecondary"))
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color("TextTertiary"))
            }
            .padding(16)
            .background(Color("SurfaceContainerLowest"))
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.default))
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NewRecipeEntryModeView()
        .environment(RecipeStore())
}
