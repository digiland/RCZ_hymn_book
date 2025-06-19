//
//  SharingView.swift
//  RCZ_hymn_book
//
//  Created by Adrian Madhigi on 19/6/2025.
//

import SwiftUI
import PDFKit
import UIKit

// MARK: - SharingView

struct SharingView: View {
    let hymn: Hymn
    let userSettings: UserSettings
    @State private var showingShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Share \(hymn.displayTitle)")
                .font(.headline)
                .padding()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ShareButton(
                    icon: "square.and.arrow.up",
                    title: "Share Text",
                    action: shareText
                )
                
                ShareButton(
                    icon: "doc.pdf",
                    title: "Export PDF",
                    action: exportPDF
                )
                
                ShareButton(
                    icon: "doc.on.clipboard",
                    title: "Copy Text",
                    action: copyToClipboard
                )
                
                ShareButton(
                    icon: "photo",
                    title: "Create Image",
                    action: generateImage
                )
            }
            .padding()
            
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
    
    private func shareText() {
        let shareText = formatHymnForSharing()
        shareItems = [shareText]
        showingShareSheet = true
    }
    
    private func exportPDF() {
        if let pdfData = generatePDF() {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(hymn.displayTitle).pdf")
            
            do {
                try pdfData.write(to: tempURL)
                shareItems = [tempURL]
                showingShareSheet = true
            } catch {
                alertMessage = "Failed to create PDF: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }
    
    private func copyToClipboard() {
        let shareText = formatHymnForSharing()
        UIPasteboard.general.string = shareText
        alertMessage = "Hymn text copied to clipboard!"
        showingAlert = true
    }
    
    private func generateImage() {
        if let image = createHymnImage() {
            shareItems = [image]
            showingShareSheet = true
        } else {
            alertMessage = "Failed to generate image"
            showingAlert = true
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatHymnForSharing() -> String {
        var text = hymn.displayTitle + "\n\n"
        if let lyrics = hymn.lyrics {
            text += lyrics
        }
        text += "\n\nShared from RCZ Hymn Book"
        return text
    }
    
    private func generatePDF() -> Data? {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792)) // Letter size
        
        return pdfRenderer.pdfData { context in
            context.beginPage()
            
            let titleFont = UIFont.boldSystemFont(ofSize: 24)
            let bodyFont = UIFont.systemFont(ofSize: 16)
            let margin: CGFloat = 50
            let pageWidth = 612 - 2 * margin
            
            var yPosition: CGFloat = margin
            
            // Draw title
            let titleText = hymn.displayTitle
            let titleRect = CGRect(x: margin, y: yPosition, width: pageWidth, height: 40)
            titleText.draw(in: titleRect, withAttributes: [
                .font: titleFont,
                .foregroundColor: UIColor.black
            ])
            yPosition += 60
            
            // Draw lyrics
            if let lyrics = hymn.lyrics {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 8
                
                let lyricsRect = CGRect(x: margin, y: yPosition, width: pageWidth, height: 692 - yPosition)
                lyrics.draw(in: lyricsRect, withAttributes: [
                    .font: bodyFont,
                    .foregroundColor: UIColor.black,
                    .paragraphStyle: paragraphStyle
                ])
            }
        }
    }
    
    private func createHymnImage() -> UIImage? {
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

// MARK: - ShareButton

struct ShareButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.primary)
                    .accessibilityHidden(true) // Icon is decorative
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.primary) // Use primary for better contrast
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6)) // Consider Color(.systemBackground) for best HIG compliance
            .cornerRadius(12)
        }
        .accessibilityLabel(Text(title))
        .accessibilityHint("Tap to " + title.lowercased())
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - ActivityViewController

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
