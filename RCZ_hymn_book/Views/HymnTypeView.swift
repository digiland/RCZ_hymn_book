//
//  HymnTypeView.swift
//  RCZ_hymn_book
//
//  Created by Adrian Madhigi on 18/6/2025.
//

import SwiftUI

struct HymnTypeView: View {
    let hymnType: String
    @ObservedObject var hymnStore: HymnStore
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $searchText, onSearchTextChanged: searchHymns)
                
                if hymnStore.isLoading || hymnStore.isFiltering {
                    ProgressView("Loading \(hymnType.lowercased())s...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = hymnStore.errorMessage {
                    ContentUnavailableView(
                        "Error Loading \(hymnType)s",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else if hymnStore.hymns.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "No \(hymnType)s Available" : "No Results Found",
                        systemImage: searchText.isEmpty ? "music.note.list" : "magnifyingglass",
                        description: Text(searchText.isEmpty ? 
                                        "No \(hymnType.lowercased())s found in the database." : 
                                        "Try searching with different keywords.")
                    )
                } else {
                    List(hymnStore.hymns) { hymn in
                        NavigationLink(destination: HymnDetailView(hymnStore: hymnStore, hymn: hymn)) {
                            HymnRow(hymn: hymn)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(hymnType)
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                hymnStore.filterHymns(byType: hymnType)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func searchHymns() {
        hymnStore.searchAndFilter(query: searchText, type: hymnType)
    }
}

#Preview {
    HymnTypeView(hymnType: "Guide", hymnStore: HymnStore())
}
