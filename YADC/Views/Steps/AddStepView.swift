//
//  AddStepView.swift
//  YADC
//
//  Created by Claude on 13.12.2025.
//

import SwiftUI

struct AddStepView: View {
    @Environment(RecipeViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    @State private var description = ""
    @State private var hasWaitingTime = false
    @State private var waitingTimeMinutes = 30
    @State private var hasTemperature = false
    @State private var temperature = 25.0

    var body: some View {
        NavigationStack {
            Form {
                Section("Description") {
                    TextField("Step description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                        .listRowBackground(Color("FormRowBackground"))
                }

                Section("Waiting Time") {
                    Toggle("Has waiting time", isOn: $hasWaitingTime)
                        .tint(Color("AccentColor"))
                        .listRowBackground(Color("FormRowBackground"))

                    if hasWaitingTime {
                        Stepper(
                            formatDuration(waitingTimeMinutes),
                            value: $waitingTimeMinutes,
                            in: 1...1440,
                            step: stepValue
                        )
                        .tint(Color("AccentColor"))
                        .listRowBackground(Color("FormRowBackground"))

                        HStack {
                            ForEach([30, 60, 120, 720, 1440], id: \.self) { minutes in
                                Button(formatQuickTime(minutes)) {
                                    waitingTimeMinutes = minutes
                                }
                                .buttonStyle(.bordered)
                                .tint(minutes >= 720 ? Color("TextSecondary") : Color("AccentColor"))
                            }
                        }
                        .listRowBackground(Color("FormRowBackground"))
                    }
                }

                Section("Temperature") {
                    Toggle("Has temperature", isOn: $hasTemperature)
                        .tint(Color("AccentColor"))
                        .listRowBackground(Color("FormRowBackground"))

                    if hasTemperature {
                        Stepper(
                            "\(Int(temperature)) \(viewModel.temperatureUnit)",
                            value: $temperature,
                            in: temperatureRange,
                            step: temperatureStep
                        )
                        .tint(Color("AccentColor"))
                        .listRowBackground(Color("FormRowBackground"))

                        HStack {
                            ForEach(temperaturePresets, id: \.self) { temp in
                                Button("\(Int(temp))°") {
                                    temperature = temp
                                }
                                .buttonStyle(.bordered)
                                .tint(temp >= bakingThreshold ? Color("TextSecondary") : Color("AccentColor"))
                            }
                        }
                        .listRowBackground(Color("FormRowBackground"))
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("CreamBackground"))
            .foregroundStyle(Color("TextPrimary"))
            .navigationTitle("Add Step")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("CreamBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addStep()
                    }
                    .disabled(description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private var stepValue: Int {
        if waitingTimeMinutes < 60 {
            return 5
        } else if waitingTimeMinutes < 180 {
            return 15
        } else if waitingTimeMinutes < 360 {
            return 30
        } else {
            return 60
        }
    }

    private var temperaturePresets: [Double] {
        switch viewModel.settings.unitSystem {
        case .metric:
            return [25, 30, 180, 220, 250]
        case .imperial:
            return [77, 86, 350, 425, 480]
        }
    }

    private var bakingThreshold: Double {
        switch viewModel.settings.unitSystem {
        case .metric:
            return 100
        case .imperial:
            return 200
        }
    }

    private var temperatureRange: ClosedRange<Double> {
        switch viewModel.settings.unitSystem {
        case .metric:
            return 0...300
        case .imperial:
            return 32...570
        }
    }

    private var temperatureStep: Double {
        if temperature < bakingThreshold {
            return 1
        } else {
            return viewModel.settings.unitSystem == .metric ? 5 : 10
        }
    }

    private func formatQuickTime(_ minutes: Int) -> String {
        minutes >= 60 ? "\(minutes / 60)h" : "\(minutes)m"
    }

    private func formatDuration(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let mins = minutes % 60
            if mins == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h \(mins)m"
            }
        }
    }

    private func addStep() {
        let tempCelsius = hasTemperature ? viewModel.temperatureFromInput(temperature) : nil
        let minutes = hasWaitingTime ? waitingTimeMinutes : nil

        viewModel.addStep(
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            waitingTimeMinutes: minutes,
            temperatureCelsius: tempCelsius
        )
        dismiss()
    }
}

#Preview {
    AddStepView()
        .environment(RecipeViewModel())
}
