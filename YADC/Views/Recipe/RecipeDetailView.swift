//
//  RecipeDetailView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 14.12.2025.
//

import SwiftUI
import Combine

struct RecipeDetailView: View {
    let recipe: Recipe
    @Environment(RecipeStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditor = false

    private var currentRecipe: Recipe {
        store.recipe(withId: recipe.id) ?? recipe
    }

    var body: some View {
        List {
            Section {
                Stepper("Number of balls: \(currentRecipe.numberOfBalls)",
                        value: Binding(
                            get: { currentRecipe.numberOfBalls },
                            set: { store.updateNumberOfBalls(for: currentRecipe.id, count: $0) }
                        ),
                        in: 1...100)
                .tint(Color("AccentColor"))
                .listRowBackground(Color("FormRowBackground"))
            }

            if let preFerment = currentRecipe.ingredients.first(where: { $0.isPreFerment }) {
                Section("Pre-ferment (\(preFerment.preFermentMetadata?.type.displayName ?? ""))") {
                    DetailIngredientRow(
                        name: "Total",
                        weight: store.displayWeight(preFerment.weight),
                        unit: store.weightUnit
                    )
                    .listRowBackground(Color("FormRowBackground"))

                    if let subIngredients = preFerment.subIngredients {
                        ForEach(subIngredients) { sub in
                            DetailIngredientRow(
                                name: "  \(sub.name)",
                                weight: store.displayWeight(sub.weight),
                                unit: store.weightUnit
                            )
                            .font(.caption)
                            .listRowBackground(Color("FormRowBackground"))
                        }
                    }
                }
            }

            Section("Main Dough") {
                ForEach(currentRecipe.ingredients.filter { !$0.isPreFerment }) { ingredient in
                    DetailIngredientRow(
                        name: ingredient.name,
                        weight: store.displayWeight(ingredient.weight),
                        unit: store.weightUnit
                    )
                    .listRowBackground(Color("FormRowBackground"))
                }
            }

            Section {
                HStack {
                    Text("Total dough weight")
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(store.displayWeight(currentRecipe.totalDoughWeight).weightFormatted) \(store.weightUnit)")
                        .fontWeight(.medium)
                }
                .listRowBackground(Color("FormRowBackground"))
            }

            if !currentRecipe.steps.isEmpty {
                Section("Steps") {
                    ForEach(Array(currentRecipe.steps.enumerated()), id: \.element.id) { index, step in
                        DetailStepRow(step: step, stepNumber: index + 1, store: store)
                            .listRowBackground(Color("FormRowBackground"))
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color("CreamBackground"))
        .foregroundStyle(Color("TextPrimary"))
        .navigationTitle(currentRecipe.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color("CreamBackground"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showingEditor = true
                }
            }
        }
        .fullScreenCover(isPresented: $showingEditor) {
            RecipeEditorView(recipe: currentRecipe)
        }
        .toolbar(.hidden, for: .tabBar)
    }
}

struct DetailIngredientRow: View {
    let name: String
    let weight: Double
    let unit: String

    var body: some View {
        HStack {
            Text(name)
            Spacer()
            Text("\(weight.weightFormatted) \(unit)")
                .foregroundStyle(Color("TextSecondary"))
        }
    }
}

struct DetailStepRow: View {
    let step: Step
    let stepNumber: Int
    let store: RecipeStore

    @State private var refreshTrigger = false

    private var timerService: TimerService { .shared }

    private var timerIsActive: Bool {
        timerService.isTimerActive(for: step.id)
    }

    private var timerIsPaused: Bool {
        timerService.isTimerPaused(for: step.id)
    }

    private var remainingSeconds: Int? {
        timerService.remainingTime(for: step.id)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text("\(stepNumber).")
                    .foregroundStyle(Color("TextSecondary"))
                    .frame(width: 24, alignment: .leading)
                Text(step.description)
            }

            HStack(spacing: 16) {
                if step.hasTimer {
                    if timerIsActive, let remaining = remainingSeconds {
                        HStack(spacing: 8) {
                            Image(systemName: "timer")
                                .foregroundStyle(timerIsPaused ? Color.secondary : Color("AccentColor"))
                            Text(formatTime(remaining))
                                .monospacedDigit()
                                .foregroundStyle(timerIsPaused ? Color.secondary : Color("AccentColor"))

                            if timerIsPaused {
                                Button {
                                    timerService.resumeTimer(for: step.id)
                                } label: {
                                    Image(systemName: "play.fill")
                                        .font(.caption)
                                }
                                .buttonStyle(.bordered)
                                .tint(Color("AccentColor"))
                            } else {
                                Button {
                                    timerService.pauseTimer(for: step.id)
                                } label: {
                                    Image(systemName: "pause.fill")
                                        .font(.caption)
                                }
                                .buttonStyle(.bordered)
                                .tint(Color("TextSecondary"))
                            }

                            Button {
                                timerService.stopTimer(for: step.id)
                            } label: {
                                Image(systemName: "stop.fill")
                                    .font(.caption)
                            }
                            .buttonStyle(.bordered)
                            .tint(Color("TextTertiary"))
                        }
                    } else {
                        Button {
                            timerService.requestNotificationPermissions()
                            timerService.startTimer(for: step)
                        } label: {
                            Label(formatDuration(step.waitingTimeMinutes!), systemImage: "play.fill")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .tint(Color("AccentColor"))
                    }
                }

                if let temp = step.temperatureCelsius {
                    Label(
                        "\(Int(store.displayTemperature(temp)))\(store.temperatureUnit)",
                        systemImage: "thermometer.medium"
                    )
                    .font(.caption)
                    .foregroundStyle(Color("TextSecondary"))
                }
            }
        }
        .padding(.vertical, 4)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if timerIsActive {
                timerService.updateTimers()
                refreshTrigger.toggle()
            }
        }
        .id(refreshTrigger)
    }

    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }

    private func formatDuration(_ minutes: Int) -> String {
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            if mins == 0 {
                return "\(hours)h"
            }
            return "\(hours)h \(mins)m"
        }
        return "\(minutes) min"
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(recipe: Recipe.default)
    }
    .environment(RecipeStore())
}
