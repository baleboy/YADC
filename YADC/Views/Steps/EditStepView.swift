//
//  EditStepView.swift
//  YADC
//
//  Created by Claude on 13.12.2025.
//

import SwiftUI

struct EditStepView: View {
    @Environment(RecipeViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    let step: Step

    @State private var description: String
    @State private var hasWaitingTime: Bool
    @State private var waitingTimeMinutes: Int
    @State private var hasTemperature: Bool
    @State private var temperature: Double

    init(step: Step) {
        self.step = step
        _description = State(initialValue: step.description)
        _hasWaitingTime = State(initialValue: step.waitingTimeMinutes != nil)
        _waitingTimeMinutes = State(initialValue: step.waitingTimeMinutes ?? 30)
        _hasTemperature = State(initialValue: step.temperatureCelsius != nil)
        _temperature = State(initialValue: step.temperatureCelsius ?? 25.0)
    }

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
            .navigationTitle("Edit Step")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("CreamBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveStep()
                    }
                    .disabled(description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if let celsius = step.temperatureCelsius {
                    temperature = viewModel.displayTemperature(celsius)
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

    private func saveStep() {
        let tempCelsius = hasTemperature ? viewModel.temperatureFromInput(temperature) : nil
        let minutes = hasWaitingTime ? waitingTimeMinutes : nil

        viewModel.updateStep(
            id: step.id,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            waitingTimeMinutes: minutes,
            temperatureCelsius: tempCelsius
        )
        dismiss()
    }
}

#Preview {
    EditStepView(step: Step(
        description: "Mix flour and water",
        waitingTimeMinutes: 30,
        temperatureCelsius: 25
    ))
    .environment(RecipeViewModel())
}
