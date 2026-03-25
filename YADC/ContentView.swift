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
        ZStack(alignment: .bottom) {
            // Tab content
            Group {
                switch selectedTab {
                case 0: RecipeListView()
                case 1: BakeInProgressView()
                case 2: SettingsView()
                default: RecipeListView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom pill tab bar
            pillTabBar
        }
        .ignoresSafeArea(.keyboard)
        .onChange(of: navigationManager.shouldSwitchToBakesTab) { _, shouldSwitch in
            if shouldSwitch {
                withAnimation(.spring(duration: 0.3)) {
                    selectedTab = 1
                }
            }
        }
    }

    private var pillTabBar: some View {
        HStack(spacing: 0) {
            tabButton(icon: "book.closed", label: "RECIPES", index: 0)
            tabButton(icon: "timer", label: "BAKES", index: 1, badge: bakeService.activeSessionCount)
            tabButton(icon: "gearshape", label: "SETTINGS", index: 2)
        }
        .padding(4)
        .background(
            Capsule()
                .fill(Color("SurfaceContainerLowest"))
                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
                .overlay(
                    Capsule()
                        .strokeBorder(Color("BorderSubtle"), lineWidth: 1)
                )
        )
        .padding(.horizontal, 21)
        .padding(.bottom, 21)
    }

    private func tabButton(icon: String, label: String, index: Int, badge: Int = 0) -> some View {
        Button {
            withAnimation(.spring(duration: 0.3)) {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.system(size: 18))

                    if badge > 0 {
                        Text("\(badge)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 16, height: 16)
                            .background(Color("AccentColor"))
                            .clipShape(Circle())
                            .offset(x: 8, y: -6)
                    }
                }

                Text(label)
                    .font(.system(size: 10, weight: selectedTab == index ? .semibold : .medium))
                    .tracking(0.5)
            }
            .foregroundStyle(selectedTab == index ? .white : Color("TabInactive"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                selectedTab == index
                    ? Capsule().fill(Color("AccentColor"))
                    : Capsule().fill(Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
        .environment(RecipeStore())
        .environment(JournalStore())
        .environment(NavigationManager.shared)
}
