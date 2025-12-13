//
//  RecipeStepRow.swift
//  YADC
//
//  Created by Claude on 13.12.2025.
//

import SwiftUI
import Combine

struct RecipeStepRow: View {
    @Environment(RecipeViewModel.self) private var viewModel
    let step: Step
    let stepNumber: Int

    @State private var refreshTrigger = false

    private var timerIsActive: Bool {
        viewModel.timerService.isTimerActive(for: step.id)
    }

    private var timerIsPaused: Bool {
        viewModel.timerService.isTimerPaused(for: step.id)
    }

    private var remainingSeconds: Int? {
        viewModel.timerService.remainingTime(for: step.id)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text("\(stepNumber).")
                    .foregroundStyle(.secondary)
                    .frame(width: 24, alignment: .leading)
                Text(step.description)
            }

            HStack(spacing: 16) {
                if step.hasTimer {
                    if timerIsActive, let remaining = remainingSeconds {
                        HStack(spacing: 8) {
                            Image(systemName: "timer")
                                .foregroundStyle(timerIsPaused ? Color.secondary : Color.orange)
                            Text(formatTime(remaining))
                                .monospacedDigit()
                                .foregroundStyle(timerIsPaused ? Color.secondary : Color.orange)

                            if timerIsPaused {
                                Button {
                                    viewModel.resumeStepTimer(for: step.id)
                                } label: {
                                    Image(systemName: "play.fill")
                                        .font(.caption)
                                }
                                .buttonStyle(.bordered)
                                .tint(.green)
                            } else {
                                Button {
                                    viewModel.pauseStepTimer(for: step.id)
                                } label: {
                                    Image(systemName: "pause.fill")
                                        .font(.caption)
                                }
                                .buttonStyle(.bordered)
                                .tint(.orange)
                            }

                            Button {
                                viewModel.stopStepTimer(for: step.id)
                            } label: {
                                Image(systemName: "stop.fill")
                                    .font(.caption)
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                        }
                    } else {
                        Button {
                            viewModel.startStepTimer(for: step)
                        } label: {
                            Label(formatDuration(step.waitingTimeMinutes!), systemImage: "play.fill")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .tint(.green)
                    }
                }

                if let temp = step.temperatureCelsius {
                    Label(
                        "\(Int(viewModel.displayTemperature(temp)))\(viewModel.temperatureUnit)",
                        systemImage: "thermometer.medium"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if timerIsActive {
                viewModel.timerService.updateTimers()
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
    List {
        RecipeStepRow(
            step: Step(
                description: "Mix flour and water",
                waitingTimeMinutes: 30,
                temperatureCelsius: 25
            ),
            stepNumber: 1
        )
        RecipeStepRow(
            step: Step(
                description: "Let the dough rest",
                waitingTimeMinutes: 60
            ),
            stepNumber: 2
        )
        RecipeStepRow(
            step: Step(description: "Add salt and knead"),
            stepNumber: 3
        )
    }
    .environment(RecipeViewModel())
}
