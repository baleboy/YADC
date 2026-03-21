//
//  BakeInProgressView.swift
//  YADC
//
//  Created by Claude on 25.1.2026.
//

import SwiftUI

struct BakeInProgressView: View {
    @Environment(RecipeStore.self) private var store
    @Environment(JournalStore.self) private var journalStore
    @Environment(NavigationManager.self) private var navigationManager
    @State private var selectedSession: BakeSession?
    @State private var bakeService = BakeSessionService.shared

    var body: some View {
        NavigationStack {
            Group {
                if !bakeService.hasActiveSessions && journalStore.entries.isEmpty {
                    ContentUnavailableView(
                        "No Bakes Yet",
                        systemImage: "flame",
                        description: Text("Start a bake from any recipe to track your progress here.")
                    )
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            // Header
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Bakes")
                                    .font(AppFont.serifHeadline(34))
                                    .foregroundStyle(Color("TextPrimary"))
                                Text("Track your baking sessions")
                                    .font(.subheadline)
                                    .foregroundStyle(Color("TextSecondary"))
                            }
                            .padding(.horizontal)

                            if bakeService.hasActiveSessions {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("IN PROGRESS")
                                        .sectionLabel()
                                        .padding(.leading, 20)

                                    VStack(spacing: 0) {
                                        ForEach(Array(bakeService.allSessions.enumerated()), id: \.element.id) { index, session in
                                            Button {
                                                selectedSession = session
                                            } label: {
                                                ActiveBakeRowView(session: session)
                                            }
                                            .buttonStyle(.plain)

                                            if index < bakeService.allSessions.count - 1 {
                                                Divider()
                                                    .padding(.leading, 16)
                                            }
                                        }
                                    }
                                    .background(Color("FormRowBackground"))
                                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.default))
                                    .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 1)
                                    .padding(.horizontal)
                                }
                            }

                            if !journalStore.entries.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("COMPLETED")
                                        .sectionLabel()
                                        .padding(.leading, 20)

                                    VStack(spacing: 12) {
                                        ForEach(journalStore.sortedEntries) { entry in
                                            NavigationLink(value: entry) {
                                                JournalRowView(entry: entry)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 100)
                    }
                }
            }
            .background(Color("CreamBackground"))
            .navigationTitle("Bakes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Autolyse")
                        .font(AppFont.serifHeadline(18))
                        .foregroundStyle(Color("AccentColor"))
                }
            }
            .navigationDestination(for: JournalEntry.self) { entry in
                JournalEntryDetailView(entry: entry)
            }
            .fullScreenCover(item: $selectedSession) { session in
                BakeStepView(sessionId: session.id)
            }
            .onChange(of: navigationManager.pendingBakeSessionId) { _, sessionId in
                if let sessionId = sessionId,
                   let session = bakeService.session(withId: sessionId) {
                    selectedSession = session
                    navigationManager.clearPendingNavigation()
                }
            }
            .onAppear {
                if let sessionId = navigationManager.pendingBakeSessionId,
                   let session = bakeService.session(withId: sessionId) {
                    selectedSession = session
                    navigationManager.clearPendingNavigation()
                }
            }
        }
    }
}

#Preview {
    BakeInProgressView()
        .environment(RecipeStore())
        .environment(JournalStore())
        .environment(NavigationManager.shared)
}
