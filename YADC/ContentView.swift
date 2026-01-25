//
//  ContentView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var navigateToRecipe: Recipe?
    @State private var timerCount = 0

    private var timerService: TimerService { .shared }
    private var bakeService: BakeSessionService { .shared }

    var body: some View {
        TabView(selection: $selectedTab) {
            RecipeListView(navigateToRecipe: $navigateToRecipe)
                .tabItem {
                    Label("Recipes", systemImage: "book")
                }
                .tag(0)

            TimersView(selectedTab: $selectedTab, navigateToRecipe: $navigateToRecipe)
                .tabItem {
                    Label("Timers", systemImage: "timer")
                }
                .badge(timerCount > 0 ? timerCount : 0)
                .tag(1)

            BakeInProgressView()
                .tabItem {
                    Label("Baking", systemImage: "flame")
                }
                .badge(bakeService.activeSessionCount > 0 ? bakeService.activeSessionCount : 0)
                .tag(2)

            JournalListView()
                .tabItem {
                    Label("Journal", systemImage: "book.pages")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
        .toolbarBackground(Color("CreamBackground"), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .tint(Color("AccentColor"))
        .onAppear {
            updateTimerCount()
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            updateTimerCount()
        }
    }

    private func updateTimerCount() {
        timerService.updateTimers()
        timerCount = timerService.totalRunningTimerCount
    }
}

#Preview {
    ContentView()
        .environment(RecipeStore())
        .environment(JournalStore())
}
