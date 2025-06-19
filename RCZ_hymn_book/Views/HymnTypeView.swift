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
    @ObservedObject var userSettings: UserSettings
    @State private var searchText = ""
    @State private var showingShareSheet = false
    @State private var showingCopyAlert = false
    @State private var copyAlertMessage = ""
    
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
                        NavigationLink(destination: HymnDetailView(hymnStore: hymnStore, hymn: hymn, userSettings: userSettings)) {
                            HymnRow(hymn: hymn)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                copyHymnToClipboard(hymn)
                            } label: {
                                Image(systemName: "doc.on.clipboard")
                            }
                            .tint(.blue)
                            
                            Button {
                                hymnStore.setFavorite(!hymn.favorite, for: hymn)
                            } label: {
                                Image(systemName: hymn.favorite ? "star.slash" : "star")
                            }
                            .tint(hymn.favorite ? .gray : .yellow)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .alert("Copied to Clipboard", isPresented: $showingCopyAlert) {
                Button("OK") { }
            } message: {
                Text(copyAlertMessage)
            }
            .navigationTitle(hymnType)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !hymnStore.hymns.isEmpty {
                        Button(action: { showingShareSheet = true }) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .accessibilityLabel("Share \(hymnType.lowercased())s")
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                NavigationView {
                    CollectionSharingView(
                        hymns: hymnStore.hymns,
                        collectionName: "\(hymnType) Collection",
                        userSettings: userSettings
                    )
                    .navigationTitle("Share \(hymnType)s")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingShareSheet = false
                            }
                        }
                    }
                }
            }
            .onAppear {
                hymnStore.filterHymns(byType: hymnType)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func copyHymnToClipboard(_ hymn: Hymn) {
        var shareText = hymn.displayTitle + "\n\n"
        if let lyrics = hymn.lyrics {
            shareText += lyrics
        }
        shareText += "\n\nShared from RCZ Hymn Book"
        
        UIPasteboard.general.string = shareText
        copyAlertMessage = "Hymn text copied to clipboard"
        showingCopyAlert = true
        
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    private func searchHymns() {
        hymnStore.searchAndFilter(query: searchText, type: hymnType)
    }
}

#Preview {
    HymnTypeView(hymnType: "Guide", hymnStore: HymnStore(), userSettings: UserSettings())
}
