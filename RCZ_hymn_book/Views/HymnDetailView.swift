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
                Text(hymn.title.strippingHTML())
                    .font(.title)
                    .multilineTextAlignment(.leading)
                
                if let lyricsText = hymn.lyrics {
                    Text(lyricsText)
                        .font(.body)
                        .lineSpacing(6)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text("No lyrics available.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle(hymn.displayTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                favoriteButton
            }
        }
    }
    
    // MARK: - View Components
    
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
