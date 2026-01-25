//
//  BakeInProgressView.swift
//  YADC
//
//  Created by Claude on 25.1.2026.
//

import SwiftUI

struct BakeInProgressView: View {
    @Environment(RecipeStore.self) private var store
    @State private var selectedSession: BakeSession?

    private var bakeService: BakeSessionService { .shared }

    var body: some View {
        NavigationStack {
            Group {
                if bakeService.hasActiveSessions {
                    List {
                        ForEach(bakeService.allSessions) { session in
                            ActiveBakeRowView(session: session)
                                .listRowBackground(Color("FormRowBackground"))
                                .onTapGesture {
                                    selectedSession = session
                                }
                        }
                        .onDelete(perform: deleteSessions)
                    }
                    .scrollContentBackground(.hidden)
                } else {
                    ContentUnavailableView(
                        "No Bakes in Progress",
                        systemImage: "flame",
                        description: Text("Start a bake from any recipe to track your progress here.")
                    )
                }
            }
            .background(Color("CreamBackground"))
            .navigationTitle("In Progress")
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
}

#Preview {
    BakeInProgressView()
        .environment(RecipeStore())
}
