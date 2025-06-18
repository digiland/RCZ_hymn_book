import Foundation

// MARK: - Hymn Model

struct Hymn: Identifiable, Codable, Hashable {
    let id: Int
    let type: String
    let key: String
    let title: String
    let data: String // JSON string containing lyrics and metadata
    let favorite: Bool
    
    // MARK: - Computed Properties
    
    /// Extracts lyrics from the JSON data string
    var lyrics: String? {
        extractLyrics(from: data)
    }
    
    /// Returns a formatted display title
    var displayTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Private Methods
    
    private func extractLyrics(from data: String) -> String? {
        guard let jsonData = data.data(using: .utf8),
              let dictionary = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let dataArray = dictionary["data"] as? [[String: Any]] else {
            return data // Fallback to raw data
        }
        
        let verses = dataArray.compactMap { $0["text"] as? String }
        return verses.joined(separator: "\n\n")
    }
}
