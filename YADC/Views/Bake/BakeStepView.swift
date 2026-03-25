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
    @State private var displayedSeconds: Int = 0
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
                ScrollView {
                    VStack(spacing: 20) {
                        // Progress section
                        progressSection(session: session)

                        // Active Step Card
                        if let currentStep = session.currentStep {
                            activeStepCard(
                                step: currentStep,
                                stepNumber: session.currentStepIndex + 1,
                                totalSteps: session.totalSteps
                            )
                        }

                        // Next Step / Complete button
                        navigationButton(session: session)

                        // All Steps list
                        allStepsList(session: session)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
                .background(Color("CreamBackground"))
                .toolbar(.hidden, for: .navigationBar)
                .safeAreaInset(edge: .top) {
                    navBar(session: session)
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

    // MARK: - Nav Bar

    private func navBar(session: BakeSession) -> some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18))
                    .foregroundStyle(Color("TextPrimary"))
            }

            Text(session.recipeName)
                .font(AppFont.body(18, weight: .semibold))
                .tracking(-0.2)
                .foregroundStyle(Color("TextPrimary"))

            Spacer()

            Button {
                showingCancelAlert = true
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16))
                    .foregroundStyle(Color("TextTertiary"))
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Color("CreamBackground"))
    }

    // MARK: - Progress

    private func progressSection(session: BakeSession) -> some View {
        VStack(spacing: 8) {
            Text("Step \(session.currentStepIndex + 1) of \(session.totalSteps)")
                .font(AppFont.caption(13, weight: .medium))
                .foregroundStyle(Color("TextSecondary"))
                .frame(maxWidth: .infinity, alignment: .leading)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color("FormRowBackground"))
                        .frame(height: 6)
                    Capsule()
                        .fill(Color("AccentColor"))
                        .frame(width: geometry.size.width * session.progress, height: 6)
                }
            }
            .frame(height: 6)
        }
    }

    // MARK: - Active Step Card

    private func activeStepCard(step: Step, stepNumber: Int, totalSteps: Int) -> some View {
        VStack(spacing: 20) {
            // "CURRENT STEP" badge
            Text("CURRENT STEP")
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.5)
                .foregroundStyle(Color("AccentColor"))
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color("AccentGreenLight"))
                .clipShape(Capsule())

            // Step title
            Text(step.description)
                .font(AppFont.heading(22))
                .tracking(-0.3)
                .foregroundStyle(Color("TextPrimary"))
                .multilineTextAlignment(.center)

            // Temperature if available
            if let temp = step.temperatureCelsius {
                Label(
                    "\(Int(store.displayTemperature(temp)))\(store.temperatureUnit)",
                    systemImage: "thermometer.medium"
                )
                .font(AppFont.body(14))
                .foregroundStyle(Color("TextSecondary"))
            }

            // Timer section
            if step.hasTimer {
                timerDisplay(step: step)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color("SurfaceContainerLowest"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color(red: 0.1, green: 0.1, blue: 0.09).opacity(0.03), radius: 12, x: 0, y: 2)
    }

    // MARK: - Timer Display

    @ViewBuilder
    private func timerDisplay(step: Step) -> some View {
        let isActive = timerService.isTimerActive(for: step.id)
        let isPaused = timerService.isTimerPaused(for: step.id)

        if isActive {
            // Timer circle
            VStack(spacing: 4) {
                Text(formatTime(displayedSeconds))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .tracking(-1)
                    .foregroundStyle(Color("TextPrimary"))
                    .monospacedDigit()
                Text("minutes left")
                    .font(AppFont.caption(12, weight: .medium))
                    .foregroundStyle(Color("TextSecondary"))
            }
            .frame(width: 160, height: 160)
            .overlay {
                Circle()
                    .strokeBorder(Color("AccentColor"), lineWidth: 4)
            }

            // Controls
            HStack(spacing: 16) {
                if isPaused {
                    // Play button
                    Button {
                        timerService.resumeTimer(for: step.id)
                    } label: {
                        Image(systemName: "play.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Color("TextPrimary"))
                            .frame(width: 48, height: 48)
                            .background(Color("FormRowBackground"))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                } else {
                    // Pause button
                    Button {
                        timerService.pauseTimer(for: step.id)
                    } label: {
                        Image(systemName: "pause")
                            .font(.system(size: 18))
                            .foregroundStyle(Color("TextPrimary"))
                            .frame(width: 48, height: 48)
                            .background(Color("FormRowBackground"))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }

                // Stop button
                Button {
                    timerService.stopTimer(for: step.id)
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(hex: "D08068"))
                        .frame(width: 48, height: 48)
                        .background(Color(hex: "F5E0D8"))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        } else {
            // Start timer button
            Button {
                timerService.requestNotificationPermissions()
                timerService.startTimer(for: step, sessionId: sessionId)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 14))
                    Text("Start Timer · \(formatDuration(step.waitingTimeMinutes ?? 0))")
                        .font(AppFont.body(15, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color("AccentColor"))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Navigation Button

    @ViewBuilder
    private func navigationButton(session: BakeSession) -> some View {
        HStack(spacing: 12) {
            if session.hasPreviousStep {
                Button {
                    bakeService.goToPreviousStep(for: sessionId)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color("TextPrimary"))
                        .frame(width: 48, height: 48)
                        .background(Color("FormRowBackground"))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            if session.hasNextStep {
                Button {
                    bakeService.advanceStep(for: sessionId)
                } label: {
                    HStack(spacing: 8) {
                        Text("Next Step")
                            .font(AppFont.body(16, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color("AccentColor"))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    completeBake(session: session)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Complete Bake")
                            .font(AppFont.body(16, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color("AccentColor"))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - All Steps List

    private func allStepsList(session: BakeSession) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("All Steps")
                .font(AppFont.body(15, weight: .semibold))
                .foregroundStyle(Color("TextPrimary"))
                .padding(.bottom, 12)

            ForEach(Array(session.steps.enumerated()), id: \.element.id) { index, step in
                stepRow(step: step, index: index, currentIndex: session.currentStepIndex, isLast: index == session.steps.count - 1)
            }
        }
    }

    private func stepRow(step: Step, index: Int, currentIndex: Int, isLast: Bool) -> some View {
        HStack(spacing: 12) {
            // Status indicator
            if index < currentIndex {
                // Completed
                ZStack {
                    Circle()
                        .fill(Color("AccentColor"))
                        .frame(width: 24, height: 24)
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                }
            } else if index == currentIndex {
                // Active
                ZStack {
                    Circle()
                        .fill(Color("AccentGreenLight"))
                        .frame(width: 24, height: 24)
                    Circle()
                        .fill(Color("AccentColor"))
                        .frame(width: 8, height: 8)
                }
            } else {
                // Upcoming
                Circle()
                    .strokeBorder(Color("BorderSubtle"), lineWidth: 1.5)
                    .frame(width: 24, height: 24)
            }

            // Step name
            Text(step.description)
                .font(AppFont.body(14, weight: index == currentIndex ? .semibold : .medium))
                .foregroundStyle(
                    index < currentIndex
                        ? Color("TextTertiary")
                        : index == currentIndex
                            ? Color("AccentColor")
                            : Color("TextPrimary")
                )
                .lineLimit(1)

            Spacer()

            // Duration
            if let minutes = step.waitingTimeMinutes {
                Text(formatDuration(minutes))
                    .font(AppFont.caption(12, weight: index == currentIndex ? .semibold : .medium))
                    .foregroundStyle(
                        index < currentIndex
                            ? Color("TextTertiary")
                            : index == currentIndex
                                ? Color("AccentColor")
                                : Color("TextSecondary")
                    )
            }
        }
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            if !isLast {
                Rectangle()
                    .fill(Color("BorderSubtle"))
                    .frame(height: 1)
            }
        }
    }

    // MARK: - Helpers

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
                displayedSeconds = seconds
                let totalSeconds = (step.waitingTimeMinutes ?? 0) * 60
                if totalSeconds > 0 {
                    timerProgress = 1.0 - (Double(seconds) / Double(totalSeconds))
                }
            }
        }
    }

    private func formatTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
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

// MARK: - Color hex initializer

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            (r, g, b) = (Double((int >> 16) & 0xFF) / 255, Double((int >> 8) & 0xFF) / 255, Double(int & 0xFF) / 255)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    BakeStepView(sessionId: UUID())
        .environment(RecipeStore())
}
