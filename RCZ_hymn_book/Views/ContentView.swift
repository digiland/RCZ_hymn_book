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
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("RCZ Hymn Book")
            .onAppear {
                hymnStore.filterHymns(byType: "Hymn")
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func searchHymns() {
        hymnStore.searchAndFilter(query: searchText, type: "Hymn")
    }
}

// MARK: - Favorites View

struct FavoritesView: View {
    @ObservedObject var hymnStore: HymnStore
    @ObservedObject var userSettings: UserSettings
    @State private var searchText = ""
    
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
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Favorites")
            .onAppear {
                hymnStore.filterFavoriteHymns()
            }
        }
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
