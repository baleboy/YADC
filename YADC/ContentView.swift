//
//  ContentView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import SwiftUI

struct ContentView: View {
    private var bakeService: BakeSessionService { .shared }

    var body: some View {
        TabView {
            RecipeListView()
                .tabItem {
                    Label("Recipes", systemImage: "book")
                }

            BakeInProgressView()
                .tabItem {
                    Label("Baking", systemImage: "flame")
                }
                .badge(bakeService.activeSessionCount > 0 ? bakeService.activeSessionCount : 0)

            JournalListView()
                .tabItem {
                    Label("Journal", systemImage: "book.pages")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .toolbarBackground(Color("CreamBackground"), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .tint(Color("AccentColor"))
    }
}

#Preview {
    ContentView()
        .environment(RecipeStore())
        .environment(JournalStore())
}
