//
//  SettingsView.swift
//  RCZ_hymn_book
//
//  Created by Adrian Madhigi on 19/6/2025.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var userSettings: UserSettings
    @Environment(\.dismiss) private var dismiss
    @State private var showingResetAlert = false
    
    let showDoneButton: Bool
    
    init(userSettings: UserSettings, showDoneButton: Bool = false) {
        self.userSettings = userSettings
        self.showDoneButton = showDoneButton
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Font Settings Section
                Section("Font Settings") {
                    // Font Size
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Font Size")
                            Spacer()
                            Text("\(Int(userSettings.fontSize))pt")
                                .foregroundColor(.secondary)
                                .font(.caption)
                                .monospacedDigit()
                        }
                        
                        Slider(value: $userSettings.fontSize, in: 12...28, step: 1) {
                            Text("Font Size")
                        }
                        .tint(.accentColor)
                    }
                    .padding(.vertical, 4)
                    
                    // Font Family
                    Picker("Font Family", selection: $userSettings.fontFamily) {
                        ForEach(FontFamily.allCases) { font in
                            Text(font.displayName)
                                .tag(font)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    // Line Spacing
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Line Spacing")
                            Spacer()
                            Text("\(Int(userSettings.lineSpacing))pt")
                                .foregroundColor(.secondary)
                                .font(.caption)
                                .monospacedDigit()
                        }
                        
                        Slider(value: $userSettings.lineSpacing, in: 2...16, step: 1) {
                            Text("Line Spacing")
                        }
                        .tint(.accentColor)
                    }
                    .padding(.vertical, 4)
                }
                
                // MARK: - Theme Settings Section
                Section("Appearance") {
                    Picker("Background Theme", selection: $userSettings.backgroundTheme) {
                        ForEach(BackgroundTheme.allCases) { theme in
                            HStack {
                                Circle()
                                    .fill(theme.backgroundColor)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    .frame(width: 20, height: 20)
                                Text(theme.displayName)
                            }
                            .tag(theme)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // MARK: - Preview Section
                Section("Live Preview") {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Sample Hymn Title")
                            .font(userSettings.titleFont)
                            .foregroundColor(userSettings.backgroundTheme.textColor)
                            .animation(.easeInOut(duration: 0.3), value: userSettings.fontSize)
                            .animation(.easeInOut(duration: 0.3), value: userSettings.fontFamily)
                        
                        Text("This is how your hymn text will appear with the current settings. You can adjust the font size, family, line spacing, and background theme to create the perfect reading experience for your needs.")
                            .font(userSettings.dynamicFont)
                            .lineSpacing(userSettings.lineSpacing)
                            .foregroundColor(userSettings.backgroundTheme.textColor)
                            .animation(.easeInOut(duration: 0.3), value: userSettings.fontSize)
                            .animation(.easeInOut(duration: 0.3), value: userSettings.fontFamily)
                            .animation(.easeInOut(duration: 0.3), value: userSettings.lineSpacing)
                    }
                    .padding()
                    .background(userSettings.backgroundTheme.backgroundColor)
                    .cornerRadius(8)
                    .animation(.easeInOut(duration: 0.3), value: userSettings.backgroundTheme)
                }
                
                // MARK: - About Section
                Section("About Reading Settings") {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Font Size Control", systemImage: "textformat.size")
                        Text("Adjust text size from 12pt to 28pt for optimal readability")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Multiple Font Families", systemImage: "textformat")
                        Text("Choose from carefully selected fonts designed for comfortable reading")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Custom Line Spacing", systemImage: "text.line.first.and.arrowtriangle.forward")
                        Text("Adjust line spacing to reduce eye strain during extended reading")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Background Themes", systemImage: "circle.lefthalf.filled")
                        Text("Choose between light, dark, sepia, or system themes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // MARK: - Reset Section
                Section {
                    Button("Reset to Defaults") {
                        showingResetAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Reading Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if showDoneButton {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
            .alert("Reset Settings", isPresented: $showingResetAlert) {
                Button("Reset", role: .destructive) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        userSettings.resetToDefaults()
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to reset all reading settings to their default values?")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView(userSettings: UserSettings(), showDoneButton: true)
}

// HIG: Settings use system Form, Section, and Picker for consistency and accessibility.
