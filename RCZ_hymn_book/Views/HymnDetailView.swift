import SwiftUI

// MARK: - HymnDetailView

struct HymnDetailView: View {
    @ObservedObject var hymnStore: HymnStore
    @ObservedObject var userSettings: UserSettings
    let hymn: Hymn
    @State private var isFavorite: Bool
    @State private var showingSettings = false
    
    // MARK: - Initialization
    
    init(hymnStore: HymnStore, hymn: Hymn, userSettings: UserSettings = UserSettings()) {
        self.hymnStore = hymnStore
        self.hymn = hymn
        self.userSettings = userSettings
        self._isFavorite = State(initialValue: hymn.favorite)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Full screen background
            userSettings.backgroundTheme.backgroundColor
                .ignoresSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(hymn.title.strippingHTML())
                        .font(userSettings.titleFont)
                        .foregroundColor(userSettings.backgroundTheme.textColor)
                        .multilineTextAlignment(.leading)
                        .accessibilityAddTraits(.isHeader)
                    
                    if let lyricsText = hymn.lyrics {
                        Text(lyricsText)
                            .font(userSettings.dynamicFont)
                            .lineSpacing(userSettings.lineSpacing)
                            .foregroundColor(userSettings.backgroundTheme.textColor)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .textSelection(.enabled) // Enable text selection for copying
                            .accessibilityLabel("Hymn lyrics")
                    } else {
                        ContentUnavailableView(
                            "No Lyrics Available",
                            systemImage: "music.note",
                            description: Text("Lyrics for this hymn are not available.")
                        )
                    }
                }
                .padding()
            }
        }
        .navigationTitle(hymn.displayTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                settingsButton
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                favoriteButton
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(userSettings: userSettings, showDoneButton: true)
        }
        .toolbarBackground(userSettings.backgroundTheme.backgroundColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
    
    // MARK: - View Components
    
    private var settingsButton: some View {
        Button(action: { showingSettings = true }) {
            Image(systemName: "textformat")
                .foregroundStyle(.secondary)
        }
        .accessibilityLabel("Reading settings")
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
            hymnStore.setFavorite(isFavorite, for: hymn)
            hapticFeedback() // Trigger haptic feedback on favorite toggle
        }
    }
    
    // MARK: - Haptic Feedback Helper
    
    private func hapticFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HymnDetailView(
            hymnStore: HymnStore(),
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
            ),
            userSettings: UserSettings()
        )
    }
}
