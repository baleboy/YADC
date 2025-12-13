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
            CalculatorView()
                .tabItem {
                    Label("Calculator", systemImage: "function")
                }

            StepsView()
                .tabItem {
                    Label("Steps", systemImage: "list.number")
                }

            RecipeView()
                .tabItem {
                    Label("Recipe", systemImage: "list.bullet")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(RecipeViewModel())
}
