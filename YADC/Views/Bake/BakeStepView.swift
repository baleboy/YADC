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
    @State private var showingCompletionAlert = false
    @State private var showingJournalEditor = false
    @State private var completedRecipeId: UUID?
    @State private var isCompleted = false
    @State private var completedSession: BakeSession?
    @State private var displayedMinutes: Int = 0
    @State private var timerProgress: Double = 0
    @State private var refreshTrigger = false

    private var bakeService: BakeSessionService { .shared }
    private var timerService: TimerService { .shared }

    private var session: BakeSession? {
        if isCompleted {
            return completedSession
        }
        return bakeService.session(withId: sessionId)
    }

    var body: some View {
        NavigationStack {
            if let session = session {
                VStack(spacing: 0) {
                    // Progress header
                    if session.totalSteps > 0 {
                        progressHeader(session: session)
                    }

                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            if let currentStep = session.currentStep {
                                stepContent(step: currentStep, stepNumber: session.currentStepIndex + 1)
                            }

                            ingredientsSummary(session: session)
                        }
                        .padding()
                    }

                    navigationFooter(session: session)
                }
                .background(Color("CreamBackground"))
                .navigationTitle(session.recipeName)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(Color("TextPrimary"))
                        }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showingCancelAlert = true
                        } label: {
                            Text("EXIT SESSION")
                                .font(.system(size: 11, weight: .semibold))
                                .tracking(0.8)
                                .foregroundStyle(Color("AccentColor"))
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
                .alert("Bake Complete!", isPresented: $showingCompletionAlert) {
                    Button("Save") {
                        showingJournalEditor = true
                    }
                    Button("Discard", role: .destructive) {
                        dismiss()
                    }
                } message: {
                    Text("Would you like to save this bake with notes and photos?")
                }
                .sheet(isPresented: $showingJournalEditor, onDismiss: {
                    dismiss()
                }) {
                    if let recipeId = completedRecipeId {
                        JournalEntryEditorView(recipeId: recipeId)
                    }
                }
                .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                    if let currentStep = session.currentStep {
                        updateTimerDisplay(for: currentStep)
                    }
                }
                .onAppear {
                    if let currentStep = session.currentStep {
                        updateTimerDisplay(for: currentStep)
                    }
                }
            } else {
                VStack {
                    Spacer()
                    ContentUnavailableView(
                        "Bake Not Found",
                        systemImage: "exclamationmark.triangle",
                        description: Text("This bake session is no longer available.")
                    )
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Text("Close")
                    }
                    .buttonStyle(GradientPrimaryButtonStyle())
                    .padding()
                }
                .background(Color("CreamBackground"))
            }
        }
    }

    @ViewBuilder
    private func progressHeader(session: BakeSession) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("Step \(session.currentStepIndex + 1) of \(session.totalSteps)")
                    .font(AppFont.serifHeadline(18))
                    .foregroundStyle(Color("TextPrimary"))
                Spacer()
                Text("\(Int(session.progress * 100))% COMPLETE")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(1.0)
                    .foregroundStyle(Color("TextSecondary"))
            }

            // Segmented progress bar
            HStack(spacing: 3) {
                ForEach(0..<session.totalSteps, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(index <= session.currentStepIndex ? Color("AccentColor") : Color("SurfaceContainerHighest"))
                        .frame(height: 6)
                }
            }
        }
        .padding(20)
    }

    @ViewBuilder
    private func stepContent(step: Step, stepNumber: Int) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(step.description)
                .font(AppFont.serifHeadline(22))
                .foregroundStyle(Color("TextPrimary"))
                .lineSpacing(4)

            if step.hasTimer || step.temperatureCelsius != nil {
                VStack(spacing: 16) {
                    if step.hasTimer {
                        timerSection(step: step)
                    }

                    if let temp = step.temperatureCelsius {
                        temperatureSection(celsius: temp)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("FormRowBackground"))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.default))
    }

    @ViewBuilder
    private func timerSection(step: Step) -> some View {
        let isActive = timerService.isTimerActive(for: step.id)
        let isPaused = timerService.isTimerPaused(for: step.id)

        VStack(spacing: 16) {
            if isActive {
                // Large timer display
                Text(formatDuration(displayedMinutes))
                    .font(AppFont.serifDisplay(56))
                    .foregroundStyle(isPaused ? Color("TextTertiary") : Color("TextPrimary"))
                    .frame(maxWidth: .infinity)

                // Controls
                HStack(spacing: 20) {
                    // Reset button
                    Button {
                        timerService.stopTimer(for: step.id)
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 16))
                            .foregroundStyle(Color("TextSecondary"))
                            .frame(width: 44, height: 44)
                            .background(Color("SecondaryContainer"))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)

                    // Play/Pause button
                    if isPaused {
                        Button {
                            timerService.resumeTimer(for: step.id)
                        } label: {
                            Image(systemName: "play.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(.white)
                                .frame(width: 64, height: 64)
                                .background(
                                    LinearGradient(
                                        colors: [Color("AccentColor"), Color("PrimaryContainer")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                                .shadow(color: Color("AccentColor").opacity(0.3), radius: 12, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button {
                            timerService.pauseTimer(for: step.id)
                        } label: {
                            Image(systemName: "pause.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(.white)
                                .frame(width: 64, height: 64)
                                .background(Color("TextSecondary"))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }

                    // Spacer for symmetry
                    Color.clear.frame(width: 44, height: 44)
                }

                ProgressView(value: timerProgress)
                    .tint(isPaused ? Color.secondary : Color("AccentColor"))
            } else {
                Button {
                    timerService.requestNotificationPermissions()
                    timerService.startTimer(for: step, sessionId: sessionId)
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "play.fill")
                        Text("Start Timer  \(formatDuration(step.waitingTimeMinutes ?? 0))")
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color("AccentColor"), Color("PrimaryContainer")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                    .shadow(color: Color("AccentColor").opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Color("SurfaceContainerHighest").opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
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
                .font(AppFont.serifHeadline(20))
                .foregroundStyle(Color("TextPrimary"))

            VStack(spacing: 0) {
                ForEach(Array(session.scaledIngredients.filter { !$0.isPreFerment }.enumerated()), id: \.element.id) { index, ingredient in
                    HStack {
                        HStack(spacing: 10) {
                            Circle()
                                .fill(Color("AccentColor").opacity(0.3))
                                .frame(width: 6, height: 6)
                            Text(ingredient.name)
                                .foregroundStyle(Color("TextPrimary"))
                        }
                        Spacer()
                        Text("\(store.displayWeight(ingredient.weight).weightFormatted) \(store.weightUnit)")
                            .foregroundStyle(Color("TextSecondary"))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
            }
            .background(Color("SurfaceContainerLowest"))
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
            .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 1)

            HStack {
                Text("Total")
                    .fontWeight(.semibold)
                Spacer()
                Text("\(store.displayWeight(session.scaledTotalWeight).weightFormatted) \(store.weightUnit)")
                    .fontWeight(.semibold)
                    .foregroundStyle(Color("AccentColor"))
            }
            .padding(16)
            .background(Color("AccentColor").opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
        }
    }

    @ViewBuilder
    private func navigationFooter(session: BakeSession) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 16) {
                if session.totalSteps > 0 {
                    Button {
                        bakeService.goToPreviousStep(for: sessionId)
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(session.hasPreviousStep ? Color("TextPrimary") : Color("TextTertiary"))
                            .frame(width: 48, height: 48)
                            .background(Color("SecondaryContainer"))
                            .clipShape(Circle())
                    }
                    .disabled(!session.hasPreviousStep)
                    .buttonStyle(.plain)

                    Spacer()

                    if session.hasNextStep {
                        Button {
                            bakeService.advanceStep(for: sessionId)
                        } label: {
                            HStack(spacing: 8) {
                                Text("Next Step")
                                    .fontWeight(.semibold)
                                Image(systemName: "chevron.right")
                            }
                        }
                        .buttonStyle(GradientPrimaryButtonStyle())
                    } else {
                        Button {
                            completeBake(session: session)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark")
                                Text("Complete Bake")
                                    .fontWeight(.semibold)
                            }
                        }
                        .buttonStyle(GradientPrimaryButtonStyle())
                    }
                } else {
                    Button {
                        completeBake(session: session)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                            Text("Complete Bake")
                                .fontWeight(.semibold)
                        }
                    }
                    .buttonStyle(GradientPrimaryButtonStyle())
                }
            }

            // Next step preview
            if session.totalSteps > 0, session.hasNextStep,
               session.currentStepIndex + 1 < session.totalSteps {
                let nextStep = session.steps[session.currentStepIndex + 1]
                Text("NEXT: \(nextStep.description.uppercased().prefix(40))")
                    .font(.system(size: 9, weight: .medium))
                    .tracking(0.8)
                    .foregroundStyle(Color("TextTertiary"))
                    .lineLimit(1)
            }
        }
        .padding(20)
        .background(
            Color("CreamBackground").opacity(0.9)
                .background(.ultraThinMaterial)
        )
    }

    private func completeBake(session: BakeSession) {
        completedRecipeId = session.recipeId
        completedSession = session
        isCompleted = true
        bakeService.completeSession(sessionId)
        showingCompletionAlert = true
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
