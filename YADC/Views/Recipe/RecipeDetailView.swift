//
//  RecipeDetailView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 14.12.2025.
//

import SwiftUI
import Combine
import PhotosUI
import UIKit

struct RecipeDetailView: View {
    let recipe: Recipe
    @Environment(RecipeStore.self) private var store
    @Environment(JournalStore.self) private var journalStore
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditor = false
    @State private var showingImageSourceSheet = false
    @State private var showingCamera = false
    @State private var showingPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingScaleSheet = false

    private let imageService = ImageService.shared

    private var currentRecipe: Recipe {
        store.recipe(withId: recipe.id) ?? recipe
    }

    private var ratingInfo: (average: Double, count: Int)? {
        journalStore.ratingInfo(for: recipe.id)
    }

    var body: some View {
        List {
            Section {
                heroImageView
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)

            Section {
                if let rating = ratingInfo {
                    HStack {
                        HStack(spacing: 4) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= Int(rating.average.rounded()) ? "star.fill" : "star")
                                    .foregroundStyle(.yellow)
                            }
                        }
                        Spacer()
                        Text(String(format: "%.1f", rating.average))
                            .font(.headline)
                            .foregroundStyle(Color("TextPrimary"))
                        Text("(\(rating.count) \(rating.count == 1 ? "bake" : "bakes"))")
                            .foregroundStyle(Color("TextSecondary"))
                    }
                } else {
                    HStack {
                        Image(systemName: "star")
                            .foregroundStyle(Color("TextTertiary"))
                        Text("No bakes yet")
                            .foregroundStyle(Color("TextTertiary"))
                    }
                }
            }
            .listRowBackground(Color("FormRowBackground"))

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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Button {
                        showingScaleSheet = true
                    } label: {
                        Image(systemName: "flame.fill")
                    }
                    Button("Edit") {
                        showingEditor = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingScaleSheet) {
            ScaleRecipeSheet(recipe: currentRecipe)
        }
        .fullScreenCover(isPresented: $showingEditor) {
            RecipeEditorView(recipe: currentRecipe)
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraView { image in
                if let image = image {
                    store.setImage(image, for: currentRecipe.id)
                }
            }
        }
        .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPhotoItem, matching: .images)
        .onChange(of: selectedPhotoItem) { _, newValue in
            Task {
                if let item = newValue,
                   let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    store.setImage(image, for: currentRecipe.id)
                }
                selectedPhotoItem = nil
            }
        }
        .confirmationDialog("Add Photo", isPresented: $showingImageSourceSheet) {
            Button("Take Photo") {
                showingCamera = true
            }
            Button("Choose from Library") {
                showingPhotoPicker = true
            }
            if currentRecipe.hasImage {
                Button("Remove Photo", role: .destructive) {
                    store.setImage(nil, for: currentRecipe.id)
                }
            }
            Button("Cancel", role: .cancel) { }
        }
        .toolbar(.hidden, for: .tabBar)
    }

    @ViewBuilder
    private var heroImageView: some View {
        if currentRecipe.hasImage,
           let image = imageService.loadImage(for: currentRecipe.id) {
            ZStack(alignment: .bottomTrailing) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 250)
                    .clipped()

                Button {
                    showingImageSourceSheet = true
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                        .shadow(radius: 2)
                }
                .padding()
            }
        } else {
            Button {
                showingImageSourceSheet = true
            } label: {
                VStack(spacing: 12) {
                    Image(systemName: "camera.fill")
                        .font(.largeTitle)
                    Text("Add Photo")
                        .font(.headline)
                }
                .foregroundStyle(Color("TextSecondary"))
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .background(Color("FormRowBackground"))
                .cornerRadius(12)
            }
            .padding()
        }
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

    @State private var displayedMinutes: Int = 0
    @State private var progress: Double = 0

    private var timerService: TimerService { .shared }

    private var totalSeconds: Int {
        (step.waitingTimeMinutes ?? 0) * 60
    }

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
                    if timerIsActive, remainingSeconds != nil {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                Image(systemName: "timer")
                                    .foregroundStyle(timerIsPaused ? Color.secondary : Color("AccentColor"))
                                Text(formatDuration(displayedMinutes))
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

                            ProgressView(value: progress)
                                .tint(timerIsPaused ? Color.secondary : Color("AccentColor"))
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
                if let seconds = remainingSeconds {
                    let newMinutes = (seconds + 59) / 60
                    if newMinutes != displayedMinutes {
                        displayedMinutes = newMinutes
                    }
                    if totalSeconds > 0 {
                        progress = 1.0 - (Double(seconds) / Double(totalSeconds))
                    }
                }
            }
        }
        .onAppear {
            if let seconds = remainingSeconds {
                displayedMinutes = (seconds + 59) / 60
                if totalSeconds > 0 {
                    progress = 1.0 - (Double(seconds) / Double(totalSeconds))
                }
            }
        }
        .onChange(of: timerIsActive) {
            if timerIsActive, let seconds = remainingSeconds {
                displayedMinutes = (seconds + 59) / 60
                progress = 0
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
    NavigationStack {
        RecipeDetailView(recipe: Recipe.default)
    }
    .environment(RecipeStore())
    .environment(JournalStore())
}
