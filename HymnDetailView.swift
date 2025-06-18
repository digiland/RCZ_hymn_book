import SwiftUI

struct HymnDetailView: View {
    let hymn: Hymn
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(hymn.title)
                    .font(.largeTitle)
                    .bold()
                Text("Key: \(hymn.key)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Divider()
                if let lyrics = extractLyrics(from: hymn.data) {
                    Text(lyrics)
                        .font(.body)
                        .padding(.top, 8)
                } else {
                    Text("No lyrics available.")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle(hymn.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func extractLyrics(from data: String) -> String? {
        // Try to extract the lyrics from the JSON string
        if let jsonData = data.data(using: .utf8),
           let dict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
           let title = dict["title"] as? String,
           let dataArr = dict["data"] as? [[String: Any]] {
            let verses = dataArr.compactMap { $0["text"] as? String }
            return ([title] + verses).joined(separator: "\n\n")
        }
        // fallback: show raw data
        return data
    }
}
