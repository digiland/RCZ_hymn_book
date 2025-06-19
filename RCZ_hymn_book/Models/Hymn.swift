import Foundation

// MARK: - Helper structs for decoding JSON data
private struct HymnLyricsData: Decodable {
    let data: [Verse]
}

private struct Verse: Decodable {
    let id: Int
    let text: String
}

// MARK: - Hymn Model

struct Hymn: Identifiable, Codable, Hashable {
    let id: Int
    let type: String
    let key: String
    let title: String
    let data: String // JSON string containing lyrics and metadata
    let favorite: Bool
    
    // MARK: - Computed Properties
    
    /// Extracts and formats lyrics from the JSON data string
    var lyrics: String? {
        guard let jsonData = data.data(using: .utf8) else {
            return data.formatLyrics() // Fallback for plain string
        }
        
        // Try to decode the JSON
        if let hymnData = try? JSONDecoder().decode(HymnLyricsData.self, from: jsonData) {
            // Format each stanza individually, then join them with paragraph breaks.
            return hymnData.data
                .map { $0.text.formatLyrics() }
                .joined(separator: "\n\n")
        }
        
        // If decoding fails, assume data is a plain string with lyrics
        return data.formatLyrics()
    }
    
    /// Returns a formatted display title
    var displayTitle: String {
        "\(key). \(title.strippingHTML())"
    }
    
    var titleWithMarkdown: String {
        title.replacingOccurrences(of: "<b>", with: "**")
             .replacingOccurrences(of: "</b>", with: "**")
             .replacingOccurrences(of: "<i>", with: "*")
             .replacingOccurrences(of: "</i>", with: "*")
    }
}

extension String {
    /// Removes HTML tags from a string.
    func strippingHTML() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
    
    /// Converts HTML line breaks to actual line breaks and removes HTML tags
    func formatLyrics() -> String {
        var formattedText = self
        
        // Convert HTML line breaks to actual line breaks
        formattedText = formattedText.replacingOccurrences(of: "<br/>", with: "\n")
        formattedText = formattedText.replacingOccurrences(of: "<br>", with: "\n")
        
        // Remove all HTML tags completely
        formattedText = formattedText.strippingHTML()
        
        return formattedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
