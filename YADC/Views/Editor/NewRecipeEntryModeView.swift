//
//  NewRecipeEntryModeView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 15.12.2025.
//

import SwiftUI

struct NewRecipeEntryModeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMode: CalculatorMode?
    @State private var showingEditor = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("How would you like to enter your recipe?")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)

                VStack(spacing: 16) {
                    // By Percentage option
                    Button {
                        selectedMode = .forward
                        showingEditor = true
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "percent")
                                    .font(.title2)
                                Text("By Percentage")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            Text("Enter hydration and ingredient percentages, and the app calculates the weights for you.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("FormRowBackground"))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)

                    // By Weight option
                    Button {
                        selectedMode = .reverse
                        showingEditor = true
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "scalemass")
                                    .font(.title2)
                                Text("By Weight")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            Text("Enter ingredient weights from a cookbook or existing recipe, and the app calculates the percentages.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("FormRowBackground"))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)

                Spacer()
            }
            .background(Color("CreamBackground"))
            .navigationTitle("New Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("CreamBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .fullScreenCover(isPresented: $showingEditor) {
                if let mode = selectedMode {
                    RecipeEditorView(recipe: nil, initialMode: mode)
                }
            }
        }
    }
}

#Preview {
    NewRecipeEntryModeView()
        .environment(RecipeStore())
}
