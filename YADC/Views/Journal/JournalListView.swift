//
//  JournalListView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 21.12.2025.
//

import SwiftUI

struct JournalListView: View {
    @Environment(JournalStore.self) private var journalStore

    var body: some View {
        NavigationStack {
            Group {
                if journalStore.entries.isEmpty {
                    ContentUnavailableView {
                        Label("No Journal Entries", systemImage: "book.pages")
                    } description: {
                        Text("Add entries from the recipe detail view")
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            // Header
                            VStack(alignment: .leading, spacing: 4) {
                                Text("The Artisan's Ledger")
                                    .font(AppFont.serifItalic(16))
                                    .foregroundStyle(Color("BrownDark"))

                                Text("Your Baking Journey")
                                    .font(AppFont.serifHeadline(34))
                                    .foregroundStyle(Color("TextPrimary"))
                            }
                            .padding(.horizontal)

                            // Entries
                            LazyVStack(spacing: 12) {
                                ForEach(journalStore.sortedEntries) { entry in
                                    NavigationLink(value: entry) {
                                        JournalRowView(entry: entry)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 100)
                    }
                }
            }
            .background(Color("CreamBackground"))
            .navigationTitle("Journal")
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
        }
    }
}

#Preview {
    JournalListView()
        .environment(JournalStore())
        .environment(RecipeStore())
}
