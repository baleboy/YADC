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
                    List {
                        ForEach(journalStore.sortedEntries) { entry in
                            NavigationLink(value: entry) {
                                JournalRowView(entry: entry)
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color("FormRowBackground"))
                        }
                        .onDelete(perform: deleteEntries)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Color("CreamBackground"))
            .navigationTitle("Journal")
            .navigationDestination(for: JournalEntry.self) { entry in
                JournalEntryDetailView(entry: entry)
            }
            .toolbarBackground(Color("CreamBackground"), for: .navigationBar)
        }
    }

    private func deleteEntries(at offsets: IndexSet) {
        journalStore.deleteEntries(at: offsets)
    }
}

#Preview {
    JournalListView()
        .environment(JournalStore())
        .environment(RecipeStore())
}
