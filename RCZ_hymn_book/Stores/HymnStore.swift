import Foundation
import SQLite3

// MARK: - HymnStore

@MainActor
final class HymnStore: ObservableObject {
    @Published var hymns: [Hymn] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    nonisolated private let databasePointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
    
    private var database: OpaquePointer? {
        get { databasePointer.pointee }
        set { databasePointer.pointee = newValue }
    }
    
    // MARK: - Initialization
    
    init() {
        databasePointer.initialize(to: nil)
        openDatabase()
    }
    
    deinit {
        closeDatabase()
        databasePointer.deallocate()
    }
    
    // MARK: - Public Methods
    
    func fetchAllHymns() {
        Task {
            await loadHymns(with: nil)
        }
    }
    
    func searchHymns(query: String) {
        Task {
            await loadHymns(with: query)
        }
    }
    
    // MARK: - Private Methods
    
    private func openDatabase() {
        guard let dbPath = Bundle.main.path(forResource: "rcz", ofType: "db") else {
            errorMessage = "Database file not found in bundle"
            return
        }
        
        let result = sqlite3_open(dbPath, &database)
        if result != SQLITE_OK {
            errorMessage = "Unable to open database: \(String(cString: sqlite3_errmsg(database)))"
            sqlite3_close(database)
            database = nil
        }
    }
    
    nonisolated private func closeDatabase() {
        if let database = databasePointer.pointee {
            sqlite3_close(database)
            databasePointer.pointee = nil
        }
    }
    
    private func loadHymns(with searchQuery: String?) async {
        isLoading = true
        errorMessage = nil
        
        let loadedHymns = await performDatabaseQuery(searchQuery: searchQuery)
        
        hymns = loadedHymns
        isLoading = false
    }
    
    private func performDatabaseQuery(searchQuery: String?) async -> [Hymn] {
        guard let database = database else {
            await MainActor.run {
                errorMessage = "Database not available"
            }
            return []
        }
        
        let query: String
        let parameters: [String]
        
        if let searchQuery = searchQuery, !searchQuery.isEmpty {
            query = """
                SELECT _id, type, key, title, data, favorite 
                FROM data 
                WHERE key LIKE ? OR title LIKE ? OR data LIKE ? 
                ORDER BY key ASC
                """
            let likeQuery = "%\(searchQuery)%"
            parameters = [likeQuery, likeQuery, likeQuery]
        } else {
            query = "SELECT _id, type, key, title, data, favorite FROM data ORDER BY key ASC"
            parameters = []
        }
        
        var statement: OpaquePointer?
        var hymns: [Hymn] = []
        
        defer {
            sqlite3_finalize(statement)
        }
        
        guard sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK else {
            await MainActor.run {
                errorMessage = "Failed to prepare SQL statement"
            }
            return []
        }
        
        // Bind parameters for search query
        for (index, parameter) in parameters.enumerated() {
            sqlite3_bind_text(statement, Int32(index + 1), parameter, -1, nil)
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let hymn = extractHymn(from: statement)
            hymns.append(hymn)
        }
        
        return hymns
    }
    
    private func extractHymn(from statement: OpaquePointer?) -> Hymn {
        let id = Int(sqlite3_column_int(statement, 0))
        let type = String(cString: sqlite3_column_text(statement, 1))
        let key = String(cString: sqlite3_column_text(statement, 2))
        let title = String(cString: sqlite3_column_text(statement, 3))
        let data = String(cString: sqlite3_column_text(statement, 4))
        let favorite = sqlite3_column_int(statement, 5) != 0
        
        return Hymn(
            id: id,
            type: type,
            key: key,
            title: title,
            data: data,
            favorite: favorite
        )
    }
}
