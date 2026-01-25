//
//  BakeStepView.swift
//  YADC
//
//  Created by Claude on 25.1.2026.
//

import SwiftUI
import Combine

struct BakeStepView: View {
    let sessionId: UUID
    @Environment(RecipeStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var showingCancelAlert = false
    @State private var displayedMinutes: Int = 0
    @State private var timerProgress: Double = 0
    @State private var refreshTrigger = false

    private var bakeService: BakeSessionService { .shared }
    private var timerService: TimerService { .shared }

    private var session: BakeSession? {
        bakeService.session(withId: sessionId)
    }

    var body: some View {
        NavigationStack {
            if let session = session, let currentStep = session.currentStep {
                VStack(spacing: 0) {
                    // Progress header
                    progressHeader(session: session)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            // Step content
                            stepContent(step: currentStep, stepNumber: session.currentStepIndex + 1)

                            // Scaled ingredients summary
                            ingredientsSummary(session: session)
                        }
                        .padding()
                    }

                    // Navigation footer
                    navigationFooter(session: session)
                }
                .background(Color("CreamBackground"))
                .navigationTitle(session.recipeName)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingCancelAlert = true
                        }
                    }
                }
                .alert("Cancel Bake?", isPresented: $showingCancelAlert) {
                    Button("Keep Baking", role: .cancel) {}
                    Button("Cancel Bake", role: .destructive) {
                        bakeService.cancelSession(sessionId)
                        dismiss()
                    }
                } message: {
                    Text("Your progress will be lost.")
                }
                .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                    updateTimerDisplay(for: currentStep)
                }
                .onAppear {
                    updateTimerDisplay(for: currentStep)
                }
            } else {
                ContentUnavailableView(
                    "Bake Not Found",
                    systemImage: "exclamationmark.triangle",
                    description: Text("This bake session is no longer available.")
                )
                .background(Color("CreamBackground"))
            }
        }
    }

    @ViewBuilder
    private func progressHeader(session: BakeSession) -> some View {
        VStack(spacing: 8) {
            Text("Step \(session.currentStepIndex + 1) of \(session.totalSteps)")
                .font(.subheadline)
                .foregroundStyle(Color("TextSecondary"))

            ProgressView(value: session.progress)
                .tint(Color("AccentColor"))
        }
        .padding()
        .background(Color("FormRowBackground"))
    }

    @ViewBuilder
    private func stepContent(step: Step, stepNumber: Int) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(step.description)
                .font(.title3)
                .foregroundStyle(Color("TextPrimary"))

            if step.hasTimer || step.temperatureCelsius != nil {
                HStack(spacing: 20) {
                    if step.hasTimer {
                        timerSection(step: step)
                    }

                    if let temp = step.temperatureCelsius {
                        temperatureSection(celsius: temp)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("FormRowBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func timerSection(step: Step) -> some View {
        let isActive = timerService.isTimerActive(for: step.id)
        let isPaused = timerService.isTimerPaused(for: step.id)

        VStack(alignment: .leading, spacing: 8) {
            if isActive {
                HStack(spacing: 12) {
                    Image(systemName: "timer")
                        .foregroundStyle(isPaused ? Color.secondary : Color("AccentColor"))

                    Text(formatDuration(displayedMinutes))
                        .font(.title2)
                        .monospacedDigit()
                        .foregroundStyle(isPaused ? Color.secondary : Color("AccentColor"))

                    Spacer()

                    if isPaused {
                        Button {
                            timerService.resumeTimer(for: step.id)
                        } label: {
                            Image(systemName: "play.fill")
                        }
                        .buttonStyle(.bordered)
                        .tint(Color("AccentColor"))
                    } else {
                        Button {
                            timerService.pauseTimer(for: step.id)
                        } label: {
                            Image(systemName: "pause.fill")
                        }
                        .buttonStyle(.bordered)
                        .tint(Color("TextSecondary"))
                    }

                    Button {
                        timerService.stopTimer(for: step.id)
                    } label: {
                        Image(systemName: "stop.fill")
                    }
                    .buttonStyle(.bordered)
                    .tint(Color("TextTertiary"))
                }

                ProgressView(value: timerProgress)
                    .tint(isPaused ? Color.secondary : Color("AccentColor"))
            } else {
                Button {
                    timerService.requestNotificationPermissions()
                    timerService.startTimer(for: step)
                } label: {
                    Label(formatDuration(step.waitingTimeMinutes ?? 0), systemImage: "play.fill")
                }
                .buttonStyle(.bordered)
                .tint(Color("AccentColor"))
            }
        }
    }

    @ViewBuilder
    private func temperatureSection(celsius: Double) -> some View {
        Label(
            "\(Int(store.displayTemperature(celsius)))\(store.temperatureUnit)",
            systemImage: "thermometer.medium"
        )
        .font(.title3)
        .foregroundStyle(Color("TextSecondary"))
    }

    @ViewBuilder
    private func ingredientsSummary(session: BakeSession) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingredients")
                .font(.headline)
                .foregroundStyle(Color("TextPrimary"))

            VStack(spacing: 8) {
                ForEach(session.scaledIngredients.filter { !$0.isPreFerment }) { ingredient in
                    HStack {
                        Text(ingredient.name)
                            .foregroundStyle(Color("TextPrimary"))
                        Spacer()
                        Text("\(store.displayWeight(ingredient.weight).weightFormatted) \(store.weightUnit)")
                            .foregroundStyle(Color("TextSecondary"))
                    }
                }
            }
            .padding()
            .background(Color("FormRowBackground"))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            HStack {
                Text("Total")
                    .fontWeight(.semibold)
                Spacer()
                Text("\(store.displayWeight(session.scaledTotalWeight).weightFormatted) \(store.weightUnit)")
                    .fontWeight(.semibold)
                    .foregroundStyle(Color("AccentColor"))
            }
            .padding()
            .background(Color("FormRowBackground"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    @ViewBuilder
    private func navigationFooter(session: BakeSession) -> some View {
        HStack(spacing: 16) {
            Button {
                bakeService.goToPreviousStep(for: sessionId)
            } label: {
                Label("Previous", systemImage: "chevron.left")
            }
            .disabled(!session.hasPreviousStep)
            .buttonStyle(.bordered)
            .tint(Color("AccentColor"))

            Spacer()

            if session.hasNextStep {
                Button {
                    bakeService.advanceStep(for: sessionId)
                } label: {
                    Label("Next", systemImage: "chevron.right")
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("AccentColor"))
            } else {
                Button {
                    bakeService.completeSession(sessionId)
                    dismiss()
                } label: {
                    Label("Done", systemImage: "checkmark")
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
        .padding()
        .background(Color("FormRowBackground"))
    }

    private func updateTimerDisplay(for step: Step) {
        if timerService.isTimerActive(for: step.id) {
            timerService.updateTimers()
            if let seconds = timerService.remainingTime(for: step.id) {
                displayedMinutes = (seconds + 59) / 60
                let totalSeconds = (step.waitingTimeMinutes ?? 0) * 60
                if totalSeconds > 0 {
                    timerProgress = 1.0 - (Double(seconds) / Double(totalSeconds))
                }
            }
        }
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
    BakeStepView(sessionId: UUID())
        .environment(RecipeStore())
}
