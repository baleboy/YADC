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
                // Hero image with back button overlay
                heroImageView

                // Detail content
                VStack(spacing: 24) {
                    // Title + subtitle
                    titleSection

                    // Stats row
                    statsRow

                    // Rating row
                    ratingRow

                    // Ingredients card
                    ingredientsCard

                    // Pre-ferment card
                    if let preFerment = currentRecipe.ingredients.first(where: { $0.isPreFerment }) {
                        preFermentCard(preFerment)
                    }

                    // Steps section
                    if !currentRecipe.steps.isEmpty {
                        stepsSection
                    }

                    // Start Bake button
                    Button {
                        showingScaleSheet = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "timer")
                                .font(.system(size: 16))
                            Text("Start Bake")
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
                .padding(.init(top: 20, leading: 20, bottom: 24, trailing: 20))
            }
        }
        .background(Color("CreamBackground"))
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
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
    }

    // MARK: - Hero Image

    @ViewBuilder
    private var heroImageView: some View {
        ZStack(alignment: .topLeading) {
            if currentRecipe.hasImage,
               let image = imageService.loadImage(for: currentRecipe.id) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 280)
                    .clipped()
                    .onTapGesture {
                        showingImageSourceSheet = true
                    }
            } else {
                Rectangle()
                    .fill(Color("FormRowBackground"))
                    .frame(height: 280)
                    .overlay {
                        VStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.largeTitle)
                            Text("Add Photo")
                                .font(AppFont.body(15, weight: .medium))
                        }
                        .foregroundStyle(Color("TextTertiary"))
                    }
                    .onTapGesture {
                        showingImageSourceSheet = true
                    }
            }

            // Back button
            HStack(spacing: 12) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.black.opacity(0.25))
                        .clipShape(Circle())
                }

                Spacer()

                // Edit button
                Button {
                    showingEditor = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.black.opacity(0.25))
                        .clipShape(Circle())
                }
            }
            .padding(.top, 60)
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Title

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(currentRecipe.name)
                .font(AppFont.heading(26))
                .tracking(-0.5)
                .foregroundStyle(Color("TextPrimary"))

            Text(recipeSubtitle)
                .font(AppFont.body(13))
                .foregroundStyle(Color("TextSecondary"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var recipeSubtitle: String {
        let count = currentRecipe.numberOfBalls
        let weight = store.displayWeight(currentRecipe.weightPerBall).weightFormatted
        let unit = store.weightUnit
        if count == 1 {
            return "1 ball · \(weight)\(unit)"
        }
        return "\(count) balls · \(weight)\(unit) each"
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(
                value: currentRecipe.hydration.percentageFormatted,
                label: "Hydration",
                valueColor: Color("AccentColor")
            )
            statCard(
                value: "\(currentRecipe.numberOfBalls)",
                label: "Balls",
                valueColor: Color("TextPrimary")
            )
            statCard(
                value: "\(store.displayWeight(currentRecipe.weightPerBall).weightFormatted)\(store.weightUnit)",
                label: "Each",
                valueColor: Color("TextPrimary")
            )
        }
    }

    private func statCard(value: String, label: String, valueColor: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .tracking(-0.3)
                .foregroundStyle(valueColor)
            Text(label)
                .font(AppFont.caption(11, weight: .medium))
                .foregroundStyle(Color("TextTertiary"))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 70)
        .background(Color("SurfaceContainerLowest"))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
        .shadow(color: Color(red: 0.1, green: 0.1, blue: 0.09).opacity(0.03), radius: 6, x: 0, y: 1)
    }

    // MARK: - Rating Row

    private var ratingRow: some View {
        HStack(spacing: 6) {
            if let rating = ratingInfo {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= Int(rating.average.rounded()) ? "star.fill" : "star")
                        .font(.system(size: 14))
                        .foregroundStyle(
                            star <= Int(rating.average.rounded())
                                ? Color("AccentCoral")
                                : Color("BorderSubtle")
                        )
                }
                Text("\(String(format: "%.1f", rating.average)) · \(rating.count) bake\(rating.count == 1 ? "" : "s")")
                    .font(AppFont.caption(13, weight: .medium))
                    .foregroundStyle(Color("TextSecondary"))
            } else {
                ForEach(1...5, id: \.self) { _ in
                    Image(systemName: "star")
                        .font(.system(size: 14))
                        .foregroundStyle(Color("BorderSubtle"))
                }
                Text("No bakes yet")
                    .font(AppFont.caption(13, weight: .medium))
                    .foregroundStyle(Color("TextTertiary"))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Ingredients Card

    private var ingredientsCard: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Ingredients")
                    .font(AppFont.body(18, weight: .semibold))
                    .tracking(-0.2)
                    .foregroundStyle(Color("TextPrimary"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.init(top: 14, leading: 16, bottom: 14, trailing: 16))

            // Ingredient rows
            ForEach(currentRecipe.ingredients.filter({ !$0.isPreFerment })) { ingredient in
                ingredientRow(name: ingredient.name, weight: store.displayWeight(ingredient.weight), unit: store.weightUnit)
            }
        }
        .background(Color("SurfaceContainerLowest"))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.default))
        .shadow(color: Color(red: 0.1, green: 0.1, blue: 0.09).opacity(0.03), radius: 12, x: 0, y: 2)
    }

    // MARK: - Pre-ferment Card

    private func preFermentCard(_ preFerment: Ingredient) -> some View {
        VStack(spacing: 0) {
            // Header with badge
            HStack(spacing: 8) {
                Text("PRE-FERMENT")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(0.5)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color("AccentCoral"))
                    .clipShape(Capsule())

                Text(preFerment.preFermentMetadata?.type.displayName ?? "Pre-ferment")
                    .font(AppFont.body(16, weight: .semibold))
                    .foregroundStyle(Color("TextPrimary"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.init(top: 14, leading: 16, bottom: 14, trailing: 16))

            // Sub-ingredient rows
            if let subIngredients = preFerment.subIngredients {
                ForEach(subIngredients) { sub in
                    ingredientRow(
                        name: sub.name,
                        weight: store.displayWeight(sub.weight),
                        unit: store.weightUnit,
                        nameColor: Color("TextSecondary")
                    )
                }
            }
        }
        .background(Color("SurfaceContainerLowest"))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.default))
        .shadow(color: Color(red: 0.1, green: 0.1, blue: 0.09).opacity(0.03), radius: 12, x: 0, y: 2)
    }

    // MARK: - Steps Section

    private var stepsSection: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Steps")
                    .font(AppFont.body(18, weight: .semibold))
                    .tracking(-0.2)
                    .foregroundStyle(Color("TextPrimary"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.init(top: 14, leading: 16, bottom: 14, trailing: 16))

            ForEach(Array(currentRecipe.steps.enumerated()), id: \.element.id) { index, step in
                DetailStepRow(step: step, stepNumber: index + 1, store: store)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                if index < currentRecipe.steps.count - 1 {
                    Rectangle()
                        .fill(Color("BorderSubtle"))
                        .frame(height: 1)
                        .padding(.horizontal, 16)
                }
            }
        }
        .background(Color("SurfaceContainerLowest"))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.default))
        .shadow(color: Color(red: 0.1, green: 0.1, blue: 0.09).opacity(0.03), radius: 12, x: 0, y: 2)
    }

    // MARK: - Shared Row

    private func ingredientRow(name: String, weight: Double, unit: String, nameColor: Color = Color("TextPrimary")) -> some View {
        HStack {
            Text(name)
                .font(AppFont.body(14))
                .foregroundStyle(nameColor)
            Spacer()
            Text("\(weight.weightFormatted)\(unit)")
                .font(AppFont.body(14, weight: .semibold))
                .foregroundStyle(Color("TextPrimary"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color("BorderSubtle"))
                .frame(height: 1)
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
                                            .background(Color("FormRowBackground"))
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
                                        .background(Color("FormRowBackground"))
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
