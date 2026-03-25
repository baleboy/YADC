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
    @State private var selectedSegment: BakeSegment = .inProgress

    enum BakeSegment: String, CaseIterable, CustomStringConvertible {
        case inProgress = "In Progress"
        case journal = "Journal"
        var description: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    Text("Bakes")
                        .font(AppFont.heading(26))
                        .tracking(-0.5)
                        .foregroundStyle(Color("TextPrimary"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)

                    // Segmented control
                    ArtisanSegmentedPicker(
                        options: BakeSegment.allCases,
                        selection: $selectedSegment
                    )
                    .padding(.horizontal, 24)

                    // Content based on segment
                    switch selectedSegment {
                    case .inProgress:
                        inProgressContent
                    case .journal:
                        journalContent
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 100)
            }
            .background(Color("CreamBackground"))
            .toolbar(.hidden, for: .navigationBar)
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

    // MARK: - In Progress

    private var inProgressContent: some View {
        VStack(spacing: 12) {
            if bakeService.hasActiveSessions {
                ForEach(bakeService.allSessions) { session in
                    Button {
                        selectedSession = session
                    } label: {
                        ActiveBakeRowView(session: session)
                    }
                    .buttonStyle(.plain)
                }
            }

            // Empty hint
            if !bakeService.hasActiveSessions {
                emptyHint
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Journal

    private var journalContent: some View {
        VStack(spacing: 12) {
            if journalStore.entries.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "book.pages")
                        .font(.system(size: 32))
                        .foregroundStyle(Color("TextTertiary"))
                    Text("No journal entries yet")
                        .font(AppFont.caption(14, weight: .medium))
                        .foregroundStyle(Color("TextTertiary"))
                }
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
            } else {
                ForEach(journalStore.sortedEntries) { entry in
                    NavigationLink(value: entry) {
                        JournalRowView(entry: entry)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Empty Hint

    private var emptyHint: some View {
        VStack(spacing: 8) {
            Image(systemName: "frying.pan")
                .font(.system(size: 32))
                .foregroundStyle(Color("TextTertiary"))
            Text("Start a bake from any recipe!")
                .font(AppFont.caption(14, weight: .medium))
                .foregroundStyle(Color("TextTertiary"))
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    BakeInProgressView()
        .environment(RecipeStore())
        .environment(JournalStore())
        .environment(NavigationManager.shared)
}
