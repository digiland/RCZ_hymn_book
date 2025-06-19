import Foundation
import SQLite3

// MARK: - HymnStore

@MainActor
final class HymnStore: ObservableObject {
    @Published var hymns: [Hymn] = []
    @Published var isLoading = false
    @Published var isFiltering = false
    @Published var errorMessage: String?

    private var allHymns: [Hymn] = []
    private var hasLoadedData = false
    
    nonisolated private let databasePointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
    
    private var database: OpaquePointer? {
        get { databasePointer.pointee }
        set { databasePointer.pointee = newValue }
    }
    
    // MARK: - Initialization
    
    init() {
        databasePointer.initialize(to: nil)
        openDatabase()
        loadAllHymnsIfNeeded()
    }
    
    deinit {
        closeDatabase()
        databasePointer.deallocate()
    }
    
    // MARK: - Public Methods
    
    func filterHymns(byType type: String) {
        isFiltering = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Simulate async work
            self.hymns = self.allHymns.filter { $0.type.trimmingCharacters(in: .whitespacesAndNewlines).localizedCaseInsensitiveCompare(type) == .orderedSame }
            self.isFiltering = false
        }
    }
    
    func searchAndFilter(query: String, type: String) {
        isFiltering = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Simulate async work
            let filteredByType = self.allHymns.filter { $0.type.trimmingCharacters(in: .whitespacesAndNewlines).localizedCaseInsensitiveCompare(type) == .orderedSame }
            
            if query.isEmpty {
                self.hymns = filteredByType
            } else {
                let lowercasedQuery = query.lowercased()
                self.hymns = filteredByType.filter {
                    $0.key.lowercased().contains(lowercasedQuery) ||
                    $0.title.lowercased().contains(lowercasedQuery) ||
                    $0.data.lowercased().contains(lowercasedQuery)
                }
            }
            self.isFiltering = false
        }
    }
    
    // MARK: - Private Methods
    
    private func loadAllHymnsIfNeeded() {
        guard !hasLoadedData, let database = database else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task { [weak self] in
            guard let self = self else { return }
            let query = "SELECT _id, type, key, title, data, favorite FROM data ORDER BY key ASC"
            
            var statement: OpaquePointer?
            
            defer {
                sqlite3_finalize(statement)
            }
            
            var loadedHymns: [Hymn] = []
            
            if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let hymn = self.extractHymn(from: statement)
                    loadedHymns.append(hymn)
                }
            } else {
                let error = String(cString: sqlite3_errmsg(database))
                self.errorMessage = "Failed to prepare SQL statement: \(error)"
            }
            
            self.allHymns = loadedHymns
            self.hymns = loadedHymns // Initially, show all hymns
            self.isLoading = false
            self.hasLoadedData = true
        }
    }
    
    private func openDatabase() {
        guard let dbPath = Bundle.main.path(forResource: "rcz", ofType: "db") else {
            errorMessage = "Database file not found in bundle"
            return
        }
        
        if sqlite3_open(dbPath, &database) != SQLITE_OK {
            errorMessage = "Unable to open database: \(String(cString: sqlite3_errmsg(database)))"
            sqlite3_close(database)
            database = nil
        }
    }
    
    nonisolated private func closeDatabase() {
        if let db = databasePointer.pointee {
            sqlite3_close(db)
        }
    }
    
    nonisolated private func extractHymn(from statement: OpaquePointer?) -> Hymn {
        let id = Int(sqlite3_column_int(statement, 0))
        let type = String(cString: sqlite3_column_text(statement, 1))
        let keyInt = sqlite3_column_int(statement, 2)
        let key = String(keyInt)
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
