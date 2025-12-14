//
//  ContentView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            RecipeListView()
                .tabItem {
                    Label("Recipes", systemImage: "book")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .toolbarBackground(Color("CreamBackground"), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .foregroundStyle(Color("TextPrimary"))
    }
}

#Preview {
    ContentView()
        .environment(RecipeStore())
}
