//
//  StepRowView.swift
//  YADC
//
//  Created by Claude on 13.12.2025.
//

import SwiftUI

struct StepRowView: View {
    @Environment(RecipeViewModel.self) private var viewModel
    let step: Step

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(step.description)
                .font(.body)

            if step.waitingTimeMinutes != nil || step.temperatureCelsius != nil {
                HStack(spacing: 16) {
                    if let minutes = step.waitingTimeMinutes, minutes > 0 {
                        Label(formatDuration(minutes), systemImage: "clock")
                            .font(.caption)
                            .foregroundStyle(Color("TextSecondary"))
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
        }
        .padding(.vertical, 4)
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
        StepRowView(step: Step(
            description: "Mix flour and water",
            waitingTimeMinutes: 30,
            temperatureCelsius: 25
        ))
        StepRowView(step: Step(
            description: "Let the dough rest",
            waitingTimeMinutes: 60
        ))
        StepRowView(step: Step(
            description: "Add salt and knead"
        ))
    }
    .environment(RecipeViewModel())
}
