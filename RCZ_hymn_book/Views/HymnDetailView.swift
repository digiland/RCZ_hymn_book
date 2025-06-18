import SwiftUI

// MARK: - HymnDetailView

struct HymnDetailView: View {
    let hymn: Hymn
    @State private var isFavorite: Bool
    
    // MARK: - Initialization
    
    init(hymn: Hymn) {
        self.hymn = hymn
        self._isFavorite = State(initialValue: hymn.favorite)
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                Divider()
                lyricsSection
            }
            .padding()
        }
        .navigationTitle(hymn.displayTitle)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                favoriteButton
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(hymn.displayTitle)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
            
            HStack {
                Label("Key: \(hymn.key)", systemImage: "music.note")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if hymn.favorite {
                    Label("Favorite", systemImage: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }
            }
            
            if !hymn.type.isEmpty {
                Text("Type: \(hymn.type)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }
    
    private var lyricsSection: some View {
        Group {
            if let lyrics = hymn.lyrics, !lyrics.isEmpty {
                Text(lyrics)
                    .font(.body)
                    .lineSpacing(4)
                    .multilineTextAlignment(.leading)
            } else {
                ContentUnavailableView(
                    "No Lyrics Available",
                    systemImage: "music.note.list",
                    description: Text("The lyrics for this hymn are not available.")
                )
            }
        }
    }
    
    private var favoriteButton: some View {
        Button(action: toggleFavorite) {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .foregroundStyle(isFavorite ? .yellow : .secondary)
        }
        .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
    }
    
    // MARK: - Actions
    
    private func toggleFavorite() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isFavorite.toggle()
        }
        // TODO: Implement favorite persistence in HymnStore
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HymnDetailView(
            hymn: Hymn(
                id: 1,
                type: "Hymn",
                key: "001",
                title: "Sample Hymn",
                data: """
                {
                    "title": "Sample Hymn",
                    "data": [
                        {"text": "Verse 1 content here"},
                        {"text": "Verse 2 content here"}
                    ]
                }
                """,
                favorite: false
            )
        )
    }
}
