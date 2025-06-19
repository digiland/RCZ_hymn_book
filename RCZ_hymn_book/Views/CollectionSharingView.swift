//
//  CollectionSharingView.swift
//  RCZ_hymn_book
//
//  Created by Adrian Madhigi on 19/6/2025.
//

import SwiftUI
import PDFKit
import UIKit

// MARK: - CollectionSharingView

struct CollectionSharingView: View {
    let hymns: [Hymn]
    let collectionName: String
    let userSettings: UserSettings
    @State private var showingShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isGenerating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Share \(collectionName)")
                .font(.headline)
                .padding()
            
            Text("\(hymns.count) hymns selected")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ShareButton(
                    icon: "square.and.arrow.up",
                    title: "Share All Text",
                    action: shareAllText
                )
                
                ShareButton(
                    icon: "doc.pdf",
                    title: "Export PDF",
                    action: exportCollectionPDF
                )
                
                ShareButton(
                    icon: "doc.on.clipboard",
                    title: "Copy All Text",
                    action: copyAllToClipboard
                )
                
                ShareButton(
                    icon: "photo.stack",
                    title: "Create Images",
                    action: generateAllImages
                )
            }
            .padding()
            .disabled(isGenerating)
            
            if isGenerating {
                ProgressView("Generating...")
                    .padding()
            }
            
            Spacer()
        }
        .sheet(isPresented: $showingShareSheet) {
            ActivityViewController(activityItems: shareItems)
        }
        .alert("Success", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Actions
    
    private func shareAllText() {
        let shareText = formatHymnsForSharing()
        shareItems = [shareText]
        showingShareSheet = true
    }
    
    private func exportCollectionPDF() {
        isGenerating = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let pdfData = generateCollectionPDF() {
                let fileName = "\(collectionName.replacingOccurrences(of: " ", with: "_")).pdf"
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
                
                do {
                    try pdfData.write(to: tempURL)
                    DispatchQueue.main.async {
                        self.shareItems = [tempURL]
                        self.showingShareSheet = true
                        self.isGenerating = false
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.alertMessage = "Failed to create PDF: \(error.localizedDescription)"
                        self.showingAlert = true
                        self.isGenerating = false
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.alertMessage = "Failed to generate PDF"
                    self.showingAlert = true
                    self.isGenerating = false
                }
            }
        }
    }
    
    private func copyAllToClipboard() {
        let shareText = formatHymnsForSharing()
        UIPasteboard.general.string = shareText
        alertMessage = "All hymn texts copied to clipboard!"
        showingAlert = true
    }
    
    private func generateAllImages() {
        isGenerating = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            var images: [UIImage] = []
            
            for hymn in hymns {
                if let image = createHymnImage(for: hymn) {
                    images.append(image)
                }
            }
            
            DispatchQueue.main.async {
                if !images.isEmpty {
                    self.shareItems = images
                    self.showingShareSheet = true
                } else {
                    self.alertMessage = "Failed to generate images"
                    self.showingAlert = true
                }
                self.isGenerating = false
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatHymnsForSharing() -> String {
        var text = "\(collectionName)\n\n"
        
        for (index, hymn) in hymns.enumerated() {
            text += hymn.displayTitle + "\n\n"
            if let lyrics = hymn.lyrics {
                text += lyrics
            }
            
            if index < hymns.count - 1 {
                text += "\n\n" + String(repeating: "-", count: 40) + "\n\n"
            }
        }
        
        text += "\n\nShared from RCZ Hymn Book"
        return text
    }
    
    private func generateCollectionPDF() -> Data? {
        let pageSize = CGRect(x: 0, y: 0, width: 612, height: 792) // Letter size
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: pageSize)
        
        return pdfRenderer.pdfData { context in
            let margin: CGFloat = 50
            let pageWidth = pageSize.width - 2 * margin
            let pageHeight = pageSize.height - 2 * margin
            
            let titleFont = UIFont.boldSystemFont(ofSize: 24)
            let hymnTitleFont = UIFont.boldSystemFont(ofSize: 18)
            let bodyFont = UIFont.systemFont(ofSize: 14)
            
            // First page - Table of Contents
            context.beginPage()
            
            var yPosition: CGFloat = margin
            
            // Collection title
            let titleRect = CGRect(x: margin, y: yPosition, width: pageWidth, height: 40)
            collectionName.draw(in: titleRect, withAttributes: [
                .font: titleFont,
                .foregroundColor: UIColor.black
            ])
            yPosition += 60
            
            // Table of Contents
            let tocTitle = "Table of Contents"
            let tocRect = CGRect(x: margin, y: yPosition, width: pageWidth, height: 30)
            tocTitle.draw(in: tocRect, withAttributes: [
                .font: hymnTitleFont,
                .foregroundColor: UIColor.black
            ])
            yPosition += 40
            
            for hymn in hymns {
                let tocEntry = hymn.displayTitle
                let entryRect = CGRect(x: margin, y: yPosition, width: pageWidth, height: 20)
                tocEntry.draw(in: entryRect, withAttributes: [
                    .font: bodyFont,
                    .foregroundColor: UIColor.black
                ])
                yPosition += 25
                
                if yPosition > pageHeight - 50 {
                    context.beginPage()
                    yPosition = margin
                }
            }
            
            // Hymn pages
            for hymn in hymns {
                context.beginPage()
                yPosition = margin
                
                // Hymn title
                let hymnTitleRect = CGRect(x: margin, y: yPosition, width: pageWidth, height: 30)
                hymn.displayTitle.draw(in: hymnTitleRect, withAttributes: [
                    .font: hymnTitleFont,
                    .foregroundColor: UIColor.black
                ])
                yPosition += 50
                
                // Hymn lyrics
                if let lyrics = hymn.lyrics {
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.lineSpacing = 4
                    
                    let availableHeight = pageHeight - yPosition + margin
                    let lyricsRect = CGRect(x: margin, y: yPosition, width: pageWidth, height: availableHeight)
                    
                    lyrics.draw(in: lyricsRect, withAttributes: [
                        .font: bodyFont,
                        .foregroundColor: UIColor.black,
                        .paragraphStyle: paragraphStyle
                    ])
                }
            }
        }
    }
    
    private func createHymnImage(for hymn: Hymn) -> UIImage? {
        let size = CGSize(width: 800, height: 1000)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Background
            userSettings.backgroundTheme.uiColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            let margin: CGFloat = 40
            let contentWidth = size.width - 2 * margin
            
            // Title
            let titleFont = UIFont.boldSystemFont(ofSize: 28)
            let titleColor = userSettings.backgroundTheme.textUIColor
            
            var yPosition: CGFloat = margin
            let titleRect = CGRect(x: margin, y: yPosition, width: contentWidth, height: 60)
            
            hymn.displayTitle.draw(in: titleRect, withAttributes: [
                .font: titleFont,
                .foregroundColor: titleColor
            ])
            yPosition += 80
            
            // Lyrics
            if let lyrics = hymn.lyrics {
                let bodyFont = UIFont.systemFont(ofSize: 18)
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 6
                
                let lyricsRect = CGRect(x: margin, y: yPosition, width: contentWidth, height: size.height - yPosition - margin - 40)
                lyrics.draw(in: lyricsRect, withAttributes: [
                    .font: bodyFont,
                    .foregroundColor: titleColor,
                    .paragraphStyle: paragraphStyle
                ])
            }
            
            // Footer
            let footerFont = UIFont.systemFont(ofSize: 14)
            let footerText = "RCZ Hymn Book"
            let footerRect = CGRect(x: margin, y: size.height - 30, width: contentWidth, height: 20)
            footerText.draw(in: footerRect, withAttributes: [
                .font: footerFont,
                .foregroundColor: titleColor.withAlphaComponent(0.7)
            ])
        }
    }
}
