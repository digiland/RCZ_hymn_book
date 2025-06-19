//
//  SharedViews.swift
//  RCZ_hymn_book
//
//  Created by Adrian Madhigi on 18/6/2025.
//

import SwiftUI

// MARK: - Supporting Views

struct HymnRow: View {
    let hymn: Hymn
    
    var body: some View {
        HStack {
            Text("\(hymn.key). \(hymn.title)")
                .font(.headline)
            
            Spacer()
            
            if hymn.favorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
            }
        }
        .padding(.vertical, 4)
    }
}

struct SearchBar: View {
    @Binding var text: String
    let onSearchTextChanged: () -> Void
    
    var body: some View {
        HStack {
            TextField("Search by key, title, or lyrics...", text: $text)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    onSearchTextChanged()
                }
                .onChange(of: text) {
                    onSearchTextChanged()
                }
            
            if !text.isEmpty {
                Button("Clear") {
                    text = ""
                    onSearchTextChanged()
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
    }
}
