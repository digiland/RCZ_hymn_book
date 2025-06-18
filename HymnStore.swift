import Foundation
import SQLite3

class HymnStore: ObservableObject {
    @Published var hymns: [Hymn] = []
    private var db: OpaquePointer?
    
    init() {
        openDatabase()
        fetchAllHymns()
    }
    
    private func openDatabase() {
        let dbPath = Bundle.main.path(forResource: "rcz", ofType: "db")
        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            print("Unable to open database.")
        }
    }
    
    func fetchAllHymns() {
        hymns.removeAll()
        let query = "SELECT _id, type, key, title, data, favorite FROM data ORDER BY key ASC"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let type = String(cString: sqlite3_column_text(statement, 1))
                let key = String(cString: sqlite3_column_text(statement, 2))
                let title = String(cString: sqlite3_column_text(statement, 3))
                let data = String(cString: sqlite3_column_text(statement, 4))
                let favorite = sqlite3_column_int(statement, 5) != 0
                let hymn = Hymn(id: id, type: type, key: key, title: title, data: data, favorite: favorite)
                hymns.append(hymn)
            }
        }
        sqlite3_finalize(statement)
    }
    
    func searchHymns(query: String) {
        hymns.removeAll()
        let likeQuery = "%" + query + "%"
        let sql = "SELECT _id, type, key, title, data, favorite FROM data WHERE key LIKE ? OR title LIKE ? OR data LIKE ? ORDER BY key ASC"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            for i in 1...3 {
                sqlite3_bind_text(statement, Int32(i), likeQuery, -1, nil)
            }
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let type = String(cString: sqlite3_column_text(statement, 1))
                let key = String(cString: sqlite3_column_text(statement, 2))
                let title = String(cString: sqlite3_column_text(statement, 3))
                let data = String(cString: sqlite3_column_text(statement, 4))
                let favorite = sqlite3_column_int(statement, 5) != 0
                let hymn = Hymn(id: id, type: type, key: key, title: title, data: data, favorite: favorite)
                hymns.append(hymn)
            }
        }
        sqlite3_finalize(statement)
    }
}
