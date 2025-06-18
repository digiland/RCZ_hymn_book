import Foundation

struct Hymn: Identifiable {
    let id: Int
    let type: String
    let key: String
    let title: String
    let data: String // JSON string containing lyrics and metadata
    let favorite: Bool
}
