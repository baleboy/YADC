//
//  ContentView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import SwiftUI

struct ContentView: View {
    @Environment(NavigationManager.self) private var navigationManager
    @State private var bakeService = BakeSessionService.shared
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            RecipeListView()
                .tabItem {
                    Label("Recipes", systemImage: "book")
                }
                .tag(0)

            BakeInProgressView()
                .tabItem {
                    Label("Bakes", systemImage: "flame")
                }
                .badge(bakeService.activeSessionCount)
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .toolbarBackground(Color("CreamBackground"), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .tint(Color("AccentColor"))
        .onChange(of: navigationManager.shouldSwitchToBakesTab) { _, shouldSwitch in
            if shouldSwitch {
                selectedTab = 1
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(RecipeStore())
        .environment(JournalStore())
        .environment(NavigationManager.shared)
}
