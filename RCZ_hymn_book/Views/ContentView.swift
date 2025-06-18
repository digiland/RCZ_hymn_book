//
//  ContentView.swift
//  RCZ_hymn_book
//
//  Created by Adrian Madhigi on 16/6/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var hymnStore = HymnStore()
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $searchText, onSearchTextChanged: searchHymns)
                
                if hymnStore.isLoading {
                    ProgressView("Loading hymns...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = hymnStore.errorMessage {
                    ContentUnavailableView(
                        "Error Loading Hymns",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else if hymnStore.hymns.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "No Hymns Available" : "No Results Found",
                        systemImage: searchText.isEmpty ? "music.note.list" : "magnifyingglass",
                        description: Text(searchText.isEmpty ? 
                                        "The hymn database appears to be empty." : 
                                        "Try searching with different keywords.")
                    )
                } else {
                    List(hymnStore.hymns) { hymn in
                        NavigationLink(destination: HymnDetailView(hymn: hymn)) {
                            HymnRow(hymn: hymn)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("RCZ Hymn Book")
            .onAppear {
                hymnStore.fetchAllHymns()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func searchHymns() {
        if searchText.isEmpty {
            hymnStore.fetchAllHymns()
        } else {
            hymnStore.searchHymns(query: searchText)
        }
    }
}

// MARK: - Supporting Views

struct HymnRow: View {
    let hymn: Hymn
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(hymn.title)
                .font(.headline)
                .lineLimit(2)
            
            HStack {
                Text("Key: \(hymn.key)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if hymn.favorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                }
            }
            
            if !hymn.type.isEmpty {
                Text("Type: \(hymn.type)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
    }
}

struct SearchBar: View {
    @Binding var text: String
    let onSearchTextChanged: () -> Void
    
    var body: some View {
        HStack {
            TextField("Search by key, title, or lyrics...", text: $text)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    onSearchTextChanged()
                }
                .onChange(of: text) {
                    onSearchTextChanged()
                }
            
            if !text.isEmpty {
                Button("Clear") {
                    text = ""
                    onSearchTextChanged()
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
}
