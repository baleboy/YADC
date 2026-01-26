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
                    List {
                        if bakeService.hasActiveSessions {
                            Section("In Progress") {
                                ForEach(bakeService.allSessions) { session in
                                    ActiveBakeRowView(session: session)
                                        .listRowBackground(Color("FormRowBackground"))
                                        .onTapGesture {
                                            selectedSession = session
                                        }
                                }
                                .onDelete(perform: deleteSessions)
                            }
                        }

                        if !journalStore.entries.isEmpty {
                            Section("Completed") {
                                ForEach(journalStore.sortedEntries) { entry in
                                    NavigationLink(value: entry) {
                                        JournalRowView(entry: entry)
                                    }
                                    .listRowInsets(EdgeInsets())
                                    .listRowBackground(Color("FormRowBackground"))
                                }
                                .onDelete(perform: deleteEntries)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Color("CreamBackground"))
            .navigationTitle("Bakes")
            .navigationDestination(for: JournalEntry.self) { entry in
                JournalEntryDetailView(entry: entry)
            }
            .toolbarBackground(Color("CreamBackground"), for: .navigationBar)
            .fullScreenCover(item: $selectedSession) { session in
                BakeStepView(sessionId: session.id)
            }
        }
    }

    private func deleteSessions(at offsets: IndexSet) {
        let sessions = bakeService.allSessions
        for index in offsets {
            bakeService.cancelSession(sessions[index].id)
        }
    }

    private func deleteEntries(at offsets: IndexSet) {
        journalStore.deleteEntries(at: offsets)
    }
}

#Preview {
    BakeInProgressView()
        .environment(RecipeStore())
        .environment(JournalStore())
}
