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

// MARK: - Enhanced Hymn Row with Swipe Actions

struct EnhancedHymnRow: View {
    let hymn: Hymn
    let hymnStore: HymnStore
    @State private var showingCopyAlert = false
    
    var body: some View {
        HymnRow(hymn: hymn)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button {
                    copyHymnToClipboard()
                } label: {
                    Image(systemName: "doc.on.clipboard")
                }
                .tint(.blue)
                
                Button {
                    hymnStore.setFavorite(!hymn.favorite, for: hymn)
                } label: {
                    Image(systemName: hymn.favorite ? "star.slash" : "star")
                }
                .tint(hymn.favorite ? .gray : .yellow)
            }
            .alert("Copied to Clipboard", isPresented: $showingCopyAlert) {
                Button("OK") { }
            } message: {
                Text("Hymn text has been copied to clipboard")
            }
    }
    
    private func copyHymnToClipboard() {
        var shareText = hymn.displayTitle + "\n\n"
        if let lyrics = hymn.lyrics {
            shareText += lyrics
        }
        shareText += "\n\nShared from RCZ Hymn Book"
        
        UIPasteboard.general.string = shareText
        showingCopyAlert = true
        
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
}
