//
//  TimersView.swift
//  YADC
//
//  Created by Claude on 27.12.2025.
//

import SwiftUI
import Combine

struct TimersView: View {
    @Environment(RecipeStore.self) private var store
    @Binding var selectedTab: Int
    @Binding var navigateToRecipe: Recipe?
    @State private var refreshTrigger = false

    private var timerService: TimerService { .shared }

    private var activeTimerStates: [TimerService.TimerState] {
        timerService.activeTimers.values
            .filter { !$0.isExpired }
            .sorted { $0.remainingSeconds < $1.remainingSeconds }
    }

    private var expiredTimerStates: [TimerService.TimerState] {
        timerService.expiredTimers
    }

    private var timersByRecipe: [(recipe: Recipe, timers: [TimerService.TimerState])] {
        var result: [(recipe: Recipe, timers: [TimerService.TimerState])] = []
        var grouped: [UUID: [TimerService.TimerState]] = [:]

        for timerState in activeTimerStates {
            if let recipe = timerService.recipe(for: timerState.stepId, in: store.recipes) {
                grouped[recipe.id, default: []].append(timerState)
            }
        }

        for (recipeId, timers) in grouped {
            if let recipe = store.recipe(withId: recipeId) {
                result.append((recipe: recipe, timers: timers))
            }
        }

        return result.sorted { $0.recipe.name < $1.recipe.name }
    }

    private var hasAnyTimers: Bool {
        !activeTimerStates.isEmpty || !expiredTimerStates.isEmpty
    }

    var body: some View {
        NavigationStack {
            Group {
                if hasAnyTimers {
                    timerListView
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("Timers")
            .background(Color("CreamBackground"))
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "timer")
                .font(.system(size: 60))
                .foregroundStyle(Color("TextTertiary"))
            Text("No Timers")
                .font(.title2)
                .foregroundStyle(Color("TextSecondary"))
            Text("Start a timer from any recipe step")
                .font(.subheadline)
                .foregroundStyle(Color("TextTertiary"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("CreamBackground"))
    }

    private var timerListView: some View {
        List {
            // Active timers grouped by recipe
            ForEach(timersByRecipe, id: \.recipe.id) { group in
                Section {
                    ForEach(group.timers) { timerState in
                        TimerRowView(
                            timerState: timerState,
                            recipe: group.recipe,
                            onNavigate: {
                                navigateToRecipe = group.recipe
                                selectedTab = 0
                            }
                        )
                        .listRowBackground(Color("FormRowBackground"))
                    }
                } header: {
                    Button {
                        navigateToRecipe = group.recipe
                        selectedTab = 0
                    } label: {
                        HStack {
                            Text(group.recipe.name)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                    }
                    .foregroundStyle(Color("TextPrimary"))
                }
            }

            // Expired timers section
            if !expiredTimerStates.isEmpty {
                Section {
                    ForEach(expiredTimerStates) { timerState in
                        ExpiredTimerRowView(
                            timerState: timerState,
                            recipe: timerService.recipe(for: timerState.stepId, in: store.recipes),
                            onNavigate: {
                                if let recipe = timerService.recipe(for: timerState.stepId, in: store.recipes) {
                                    navigateToRecipe = recipe
                                    selectedTab = 0
                                }
                            },
                            onDismiss: {
                                timerService.dismissExpiredTimer(timerState)
                            }
                        )
                        .listRowBackground(Color("FormRowBackground"))
                    }
                } header: {
                    HStack {
                        Text("Completed")
                        Spacer()
                        if expiredTimerStates.count > 1 {
                            Button("Clear All") {
                                timerService.dismissAllExpiredTimers()
                            }
                            .font(.caption)
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color("CreamBackground"))
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            timerService.updateTimers()
            refreshTrigger.toggle()
        }
    }
}

struct TimerRowView: View {
    let timerState: TimerService.TimerState
    let recipe: Recipe
    let onNavigate: () -> Void

    @State private var remainingSeconds: Int = 0
    @State private var progress: Double = 0

    private var timerService: TimerService { .shared }

    private var isPaused: Bool {
        timerState.isPaused
    }

    private var totalSeconds: Int {
        if let step = recipe.steps.first(where: { $0.id == timerState.stepId }),
           let minutes = step.waitingTimeMinutes {
            return minutes * 60
        }
        return timerState.durationSeconds
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: onNavigate) {
                HStack {
                    Text(timerState.stepDescription)
                        .foregroundStyle(Color("TextPrimary"))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(Color("TextTertiary"))
                }
            }

            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "timer")
                        .foregroundStyle(isPaused ? Color.secondary : Color("AccentColor"))
                    Text(formatTime(remainingSeconds))
                        .monospacedDigit()
                        .fontWeight(.medium)
                        .foregroundStyle(isPaused ? Color.secondary : Color("AccentColor"))
                }

                Spacer()

                HStack(spacing: 8) {
                    if isPaused {
                        Button {
                            timerService.resumeTimer(for: timerState.stepId)
                        } label: {
                            Image(systemName: "play.fill")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .tint(Color("AccentColor"))
                    } else {
                        Button {
                            timerService.pauseTimer(for: timerState.stepId)
                        } label: {
                            Image(systemName: "pause.fill")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .tint(Color("TextSecondary"))
                    }

                    Button {
                        timerService.stopTimer(for: timerState.stepId)
                    } label: {
                        Image(systemName: "stop.fill")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .tint(Color("TextTertiary"))
                }
            }

            ProgressView(value: progress)
                .tint(isPaused ? Color.secondary : Color("AccentColor"))
        }
        .padding(.vertical, 4)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            updateTimerDisplay()
        }
        .onAppear {
            updateTimerDisplay()
        }
    }

    private func updateTimerDisplay() {
        timerService.updateTimers()
        remainingSeconds = timerState.remainingSeconds
        if totalSeconds > 0 {
            progress = 1.0 - (Double(remainingSeconds) / Double(totalSeconds))
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        }
        return String(format: "%d:%02d", minutes, secs)
    }
}

struct ExpiredTimerRowView: View {
    let timerState: TimerService.TimerState
    let recipe: Recipe?
    let onNavigate: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if let recipe = recipe {
                    Text(recipe.name)
                        .font(.caption)
                        .foregroundStyle(Color("TextTertiary"))
                }
                Button(action: onNavigate) {
                    HStack {
                        Text(timerState.stepDescription)
                            .foregroundStyle(Color("TextSecondary"))
                        Spacer()
                        if recipe != nil {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(Color("TextTertiary"))
                        }
                    }
                }
                .disabled(recipe == nil)

                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Completed")
                        .font(.caption)
                        .foregroundStyle(Color("TextTertiary"))
                    if let expiredAt = timerState.expiredAt {
                        Text("•")
                            .foregroundStyle(Color("TextTertiary"))
                        Text(expiredAt, style: .relative)
                            .font(.caption)
                            .foregroundStyle(Color("TextTertiary"))
                        Text("ago")
                            .font(.caption)
                            .foregroundStyle(Color("TextTertiary"))
                    }
                }
            }

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(Color("TextTertiary"))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TimersView(selectedTab: .constant(1), navigateToRecipe: .constant(nil))
        .environment(RecipeStore())
}
