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
            return hymnData.data
                .map { $0.text }
                .joined(separator: "\n\n")
                .formatLyrics()
        }
        
        // If decoding fails, assume data is a plain string with lyrics
        return data.formatLyrics()
    }
    
    /// Returns a formatted display title
    var displayTitle: String {
        "\(key). \(title.strippingHTML())"
    }
}

extension String {
    /// Removes HTML tags from a string.
    func strippingHTML() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
    
    /// Replaces <br> tags with newlines and strips other HTML.
    func formatLyrics() -> String {
        return self.replacingOccurrences(of: "<br/>", with: "\n")
                   .replacingOccurrences(of: "<br>", with: "\n")
                   .strippingHTML()
    }
}
