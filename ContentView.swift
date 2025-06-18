import SwiftUI

struct ContentView: View {
    @ObservedObject var store = HymnStore()
    @State private var searchText = ""
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, onSearch: {
                    if searchText.isEmpty {
                        store.fetchAllHymns()
                    } else {
                        store.searchHymns(query: searchText)
                    }
                })
                List(store.hymns) { hymn in
                    NavigationLink(destination: HymnDetailView(hymn: hymn)) {
                        VStack(alignment: .leading) {
                            Text(hymn.title)
                                .font(.headline)
                            Text("Key: \(hymn.key)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("RCZ Hymn Book")
            .background(
                colorScheme == .dark ? Color.black : Color(.systemGroupedBackground)
            )
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    var onSearch: () -> Void
    var body: some View {
        HStack {
            TextField("Search by key, title, or lyrics...", text: $text, onCommit: onSearch)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    onSearch()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal)
    }
}
