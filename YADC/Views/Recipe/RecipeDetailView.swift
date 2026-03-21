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
        ScrollView {
            VStack(spacing: 0) {
                // Hero image
                heroImageView

                // Content overlapping hero
                VStack(spacing: 24) {
                    // Title + rating card
                    VStack(spacing: 16) {
                        Text(currentRecipe.name)
                            .font(AppFont.serifHeadline(28))
                            .foregroundStyle(Color("TextPrimary"))
                            .multilineTextAlignment(.center)

                        // Rating + experience
                        HStack(spacing: 0) {
                            if let rating = ratingInfo {
                                VStack(spacing: 4) {
                                    HStack(spacing: 3) {
                                        ForEach(1...5, id: \.self) { star in
                                            Image(systemName: star <= Int(rating.average.rounded()) ? "star.fill" : "star")
                                                .font(.system(size: 14))
                                                .foregroundStyle(Color("AccentColor"))
                                        }
                                    }
                                    Text("RATING")
                                        .font(.system(size: 9, weight: .semibold))
                                        .tracking(1.2)
                                        .foregroundStyle(Color("TextSecondary"))
                                }
                                .frame(maxWidth: .infinity)

                                Rectangle()
                                    .fill(Color("OutlineVariant").opacity(0.3))
                                    .frame(width: 1, height: 40)

                                VStack(spacing: 4) {
                                    Text("\(rating.count)")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundStyle(Color("TextPrimary"))
                                    Text("BAKES")
                                        .font(.system(size: 9, weight: .semibold))
                                        .tracking(1.2)
                                        .foregroundStyle(Color("TextSecondary"))
                                }
                                .frame(maxWidth: .infinity)
                            } else {
                                HStack(spacing: 8) {
                                    Image(systemName: "star")
                                        .foregroundStyle(Color("TextTertiary"))
                                    Text("No bakes yet")
                                        .foregroundStyle(Color("TextTertiary"))
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }

                        if let prepTime = currentRecipe.formattedPreparationTime {
                            HStack {
                                Label("Preparation time", systemImage: "clock")
                                    .font(.subheadline)
                                    .foregroundStyle(Color("TextSecondary"))
                                Spacer()
                                Text(prepTime)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(Color("TextPrimary"))
                            }
                        }
                    }
                    .padding(20)
                    .background(Color("SurfaceContainerLowest"))
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.default))
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)

                    // Scaling section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Scaling")
                                .font(AppFont.serifHeadline(22))
                                .foregroundStyle(Color("TextPrimary"))
                            Spacer()
                            Text(currentRecipe.hydration.percentageFormatted + " Hydration")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(Color("AccentColor"))
                                .clipShape(Capsule())
                        }

                        ThemedStepper(
                            "Dough Balls",
                            value: Binding(
                                get: { currentRecipe.numberOfBalls },
                                set: { store.updateNumberOfBalls(for: currentRecipe.id, count: $0) }
                            ),
                            in: 1...100
                        )
                    }
                    .padding(20)
                    .background(Color("SurfaceContainerLowest"))
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.default))
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)

                    // Pre-ferment section
                    if let preFerment = currentRecipe.ingredients.first(where: { $0.isPreFerment }) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Pre-ferment (\(preFerment.preFermentMetadata?.type.displayName ?? ""))")
                                .sectionLabel()
                                .padding(.leading, 4)

                            VStack(spacing: 0) {
                                ingredientTableRow(name: "Total", weight: store.displayWeight(preFerment.weight), unit: store.weightUnit)

                                if let subIngredients = preFerment.subIngredients {
                                    ForEach(subIngredients) { sub in
                                        ingredientTableRow(name: sub.name, weight: store.displayWeight(sub.weight), unit: store.weightUnit, isSubItem: true)
                                    }
                                }
                            }
                            .background(Color("SurfaceContainerLowest"))
                            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                        }
                    }

                    // Main Dough ingredients
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Main Dough")
                                .font(AppFont.serifHeadline(22))
                                .foregroundStyle(Color("TextPrimary"))
                            Spacer()
                            Text("WEIGHTS PER \(store.displayWeight(currentRecipe.weightPerBall).weightFormatted)\(store.weightUnit) BALL")
                                .font(.system(size: 9, weight: .semibold))
                                .tracking(1.0)
                                .foregroundStyle(Color("TextSecondary"))
                        }

                        VStack(spacing: 0) {
                            // Header
                            HStack {
                                Text("INGREDIENT")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("WEIGHT")
                                    .frame(width: 80, alignment: .trailing)
                            }
                            .font(.system(size: 10, weight: .semibold))
                            .tracking(1.0)
                            .foregroundStyle(Color("TextSecondary"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color("FormRowBackground"))

                            // Ingredients
                            ForEach(currentRecipe.ingredients.filter { !$0.isPreFerment }) { ingredient in
                                ingredientTableRow(name: ingredient.name, weight: store.displayWeight(ingredient.weight), unit: store.weightUnit)
                            }

                            // Total row
                            HStack {
                                Text("Total Dough Weight")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("\(store.displayWeight(currentRecipe.totalDoughWeight).weightFormatted) \(store.weightUnit)")
                                    .fontWeight(.semibold)
                            }
                            .font(.subheadline)
                            .foregroundStyle(Color("TextPrimary"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color("AccentColor").opacity(0.06))
                        }
                        .background(Color("SurfaceContainerLowest"))
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 1)
                    }

                    // Steps
                    if !currentRecipe.steps.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Steps")
                                .font(AppFont.serifHeadline(22))
                                .foregroundStyle(Color("TextPrimary"))

                            VStack(spacing: 0) {
                                ForEach(Array(currentRecipe.steps.enumerated()), id: \.element.id) { index, step in
                                    DetailStepRow(step: step, stepNumber: index + 1, store: store)
                                        .padding(16)

                                    if index < currentRecipe.steps.count - 1 {
                                        Divider()
                                            .foregroundStyle(Color("OutlineVariant").opacity(0.15))
                                            .padding(.horizontal, 16)
                                    }
                                }
                            }
                            .background(Color("SurfaceContainerLowest"))
                            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                            .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 1)
                        }
                    }
                }
                .padding(16)
                .padding(.top, -32) // Overlap hero
            }
        }
        .background(Color("CreamBackground"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 8) {
                    Button {
                        showingScaleSheet = true
                    } label: {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(Color("AccentColor"))
                    }

                    Button {
                        showingEditor = true
                    } label: {
                        Text("EDIT")
                            .font(.system(size: 12, weight: .semibold))
                            .tracking(0.8)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Color("AccentColor"))
                            .clipShape(Capsule())
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
                    .frame(height: 300)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [Color("CreamBackground"), .clear, .clear],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )

                Button {
                    showingImageSourceSheet = true
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title)
                        .foregroundStyle(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.3), radius: 4)
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
                .frame(height: 180)
                .frame(maxWidth: .infinity)
                .background(Color("SurfaceContainerHigh"))
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.default))
            }
            .padding(16)
        }
    }

    private func ingredientTableRow(name: String, weight: Double, unit: String, isSubItem: Bool = false) -> some View {
        HStack {
            Text(name)
                .font(isSubItem ? .caption : .subheadline)
                .foregroundStyle(isSubItem ? Color("TextSecondary") : Color("TextPrimary"))
            Spacer()
            Text("\(weight.weightFormatted) \(unit)")
                .font(isSubItem ? .caption : .subheadline)
                .foregroundStyle(Color("TextSecondary"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
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
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color("AccentColor"))
                    .frame(width: 24, alignment: .leading)
                Text(step.description)
                    .foregroundStyle(Color("TextPrimary"))
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

                                Spacer()

                                if timerIsPaused {
                                    Button {
                                        timerService.resumeTimer(for: step.id)
                                    } label: {
                                        Image(systemName: "play.fill")
                                            .font(.caption)
                                            .foregroundStyle(.white)
                                            .frame(width: 28, height: 28)
                                            .background(Color("AccentColor"))
                                            .clipShape(Circle())
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    Button {
                                        timerService.pauseTimer(for: step.id)
                                    } label: {
                                        Image(systemName: "pause.fill")
                                            .font(.caption)
                                            .foregroundStyle(Color("TextSecondary"))
                                            .frame(width: 28, height: 28)
                                            .background(Color("SecondaryContainer"))
                                            .clipShape(Circle())
                                    }
                                    .buttonStyle(.plain)
                                }

                                Button {
                                    timerService.stopTimer(for: step.id)
                                } label: {
                                    Image(systemName: "stop.fill")
                                        .font(.caption)
                                        .foregroundStyle(Color("TextTertiary"))
                                        .frame(width: 28, height: 28)
                                        .background(Color("SurfaceContainerHigh"))
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
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
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(Color("AccentColor"))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
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
