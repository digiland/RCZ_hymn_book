//
//  ContentView.swift
//  RCZ_hymn_book
//
//  Created by Adrian Madhigi on 16/6/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var hymnStore = HymnStore()
    @StateObject private var userSettings = UserSettings()

    var body: some View {
        TabView {
            // Main Hymns Tab (showing only "Hymn" type)
            MainHymnsView(hymnStore: hymnStore, userSettings: userSettings)
                .tabItem {
                    Image(systemName: "music.note.list")
                    Text("Hymns")
                }
            
            // Guide Tab
            HymnTypeView(hymnType: "Guide", hymnStore: hymnStore, userSettings: userSettings)
                .tabItem {
                    Image(systemName: "book")
                    Text("Guide")
                }
            
            // Varwi Tab
            HymnTypeView(hymnType: "Varwi", hymnStore: hymnStore, userSettings: userSettings)
                .tabItem {
                    Image(systemName: "music.note")
                    Text("Varwi")
                }
            
            // Chorus Tab
            HymnTypeView(hymnType: "Chorus", hymnStore: hymnStore, userSettings: userSettings)
                .tabItem {
                    Image(systemName: "music.mic")
                    Text("Chorus")
                }
            
            // Favorites Tab
            FavoritesView(hymnStore: hymnStore, userSettings: userSettings)
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Favorites")
                }
            
            // Settings Tab
            SettingsView(userSettings: userSettings)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        .applyTheme(userSettings)
    }
}

// MARK: - Main Hymns View (for "Hymn" type only)

struct MainHymnsView: View {
    @ObservedObject var hymnStore: HymnStore
    @ObservedObject var userSettings: UserSettings
    @State private var searchText = ""
    @State private var showingCopyAlert = false
    @State private var copyAlertMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $searchText, onSearchTextChanged: searchHymns)
                
                if hymnStore.isLoading || hymnStore.isFiltering {
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
                                        "No hymns found in the database." :
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
            .navigationTitle("RCZ Hymn Book")
            .onAppear {
                hymnStore.filterHymns(byType: "Hymn")
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
        hymnStore.searchAndFilter(query: searchText, type: "Hymn")
    }
}

// MARK: - Favorites View

struct FavoritesView: View {
    @ObservedObject var hymnStore: HymnStore
    @ObservedObject var userSettings: UserSettings
    @State private var searchText = ""
    @State private var showingShareSheet = false
    @State private var showingCopyAlert = false
    @State private var copyAlertMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $searchText, onSearchTextChanged: searchFavorites)
                
                if hymnStore.isLoading || hymnStore.isFiltering {
                    ProgressView("Loading favorites...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = hymnStore.errorMessage {
                    ContentUnavailableView(
                        "Error Loading Favorites",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else if hymnStore.hymns.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "No Favorites" : "No Results Found",
                        systemImage: searchText.isEmpty ? "star.fill" : "magnifyingglass",
                        description: Text(searchText.isEmpty ?
                                        "You have not favorited any hymns yet." :
                                        "Try searching with different keywords.")
                    )
                } else {
                    List(hymnStore.hymns) { hymn in
                        NavigationLink(destination: HymnDetailView(hymnStore: hymnStore, hymn: hymn, userSettings: userSettings)) {
                            HymnRow(hymn: hymn)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                copyHymnToClipboardInFavorites(hymn)
                            } label: {
                                Image(systemName: "doc.on.clipboard")
                            }
                            .tint(.blue)
                            
                            Button {
                                hymnStore.setFavorite(false, for: hymn)
                            } label: {
                                Image(systemName: "star.slash")
                            }
                            .tint(.gray)
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
            .navigationTitle("Favorites")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !hymnStore.hymns.isEmpty {
                        Button(action: { showingShareSheet = true }) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .accessibilityLabel("Share favorites")
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                NavigationView {
                    CollectionSharingView(
                        hymns: hymnStore.hymns,
                        collectionName: "My Favorite Hymns",
                        userSettings: userSettings
                    )
                    .navigationTitle("Share Favorites")
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
                hymnStore.filterFavoriteHymns()
            }
        }
    }
    
    private func copyHymnToClipboardInFavorites(_ hymn: Hymn) {
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
    
    private func searchFavorites() {
        if searchText.isEmpty {
            hymnStore.filterFavoriteHymns()
        } else {
            hymnStore.hymns = hymnStore.allHymnsPublic.filter { $0.favorite &&
                ($0.key.localizedCaseInsensitiveContains(searchText) ||
                 $0.title.localizedCaseInsensitiveContains(searchText) ||
                 $0.data.localizedCaseInsensitiveContains(searchText))
            }
        }
    }
}

#Preview {
    ContentView()
}
