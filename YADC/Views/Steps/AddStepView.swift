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
                            "\(waitingTimeMinutes) minutes",
                            value: $waitingTimeMinutes,
                            in: 1...1440,
                            step: stepValue
                        )
                        .tint(Color("AccentColor"))
                        .listRowBackground(Color("FormRowBackground"))

                        HStack {
                            ForEach([15, 30, 60, 120], id: \.self) { minutes in
                                Button(formatQuickTime(minutes)) {
                                    waitingTimeMinutes = minutes
                                }
                                .buttonStyle(.bordered)
                                .tint(Color("AccentColor"))
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
                        HStack {
                            TextField(
                                "",
                                value: $temperature,
                                format: .number.precision(.fractionLength(0))
                            )
                            .keyboardType(.decimalPad)
                            .themedTextField()
                            .frame(width: 80)

                            Text(viewModel.temperatureUnit)
                                .foregroundStyle(Color("TextSecondary"))
                        }
                        .listRowBackground(Color("FormRowBackground"))

                        Slider(value: $temperature, in: temperatureRange, step: 1)
                            .tint(Color("AccentColor"))
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
        } else {
            return 30
        }
    }

    private var temperatureRange: ClosedRange<Double> {
        switch viewModel.settings.unitSystem {
        case .metric:
            return 0...50
        case .imperial:
            return 32...122
        }
    }

    private func formatQuickTime(_ minutes: Int) -> String {
        minutes >= 60 ? "\(minutes / 60)h" : "\(minutes)m"
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
