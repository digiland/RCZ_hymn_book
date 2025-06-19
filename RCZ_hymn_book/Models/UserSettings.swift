//
//  UserSettings.swift
//  RCZ_hymn_book
//
//  Created by Adrian Madhigi on 19/6/2025.
//

import SwiftUI
import Foundation

// MARK: - Font Family Enum

enum FontFamily: String, CaseIterable, Identifiable {
    case system = "System"
    case georgia = "Georgia"
    case times = "Times New Roman"
    case helvetica = "Helvetica"
    case palatino = "Palatino"
    case baskerville = "Baskerville"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .system: return "System Default"
        case .georgia: return "Georgia"
        case .times: return "Times New Roman"
        case .helvetica: return "Helvetica"
        case .palatino: return "Palatino"
        case .baskerville: return "Baskerville"
        }
    }
    
    var font: Font {
        switch self {
        case .system: return .system(.body)
        case .georgia: return .custom("Georgia", size: 16)
        case .times: return .custom("Times New Roman", size: 16)
        case .helvetica: return .custom("Helvetica", size: 16)
        case .palatino: return .custom("Palatino", size: 16)
        case .baskerville: return .custom("Baskerville", size: 16)
        }
    }
}

// MARK: - Background Theme Enum

enum BackgroundTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    case sepia = "Sepia"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .system: return "System Default"
        case .light: return "Light"
        case .dark: return "Dark"
        case .sepia: return "Sepia"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .system: return Color(.systemBackground)
        case .light: return Color.white
        case .dark: return Color(red: 0.05, green: 0.05, blue: 0.05) // Very dark gray instead of pure black
        case .sepia: return Color(red: 0.97, green: 0.94, blue: 0.85)
        }
    }
    
    var textColor: Color {
        switch self {
        case .system: return Color(.label)
        case .light: return Color.black
        case .dark: return Color(red: 0.95, green: 0.95, blue: 0.95) // Off-white for better readability
        case .sepia: return Color(red: 0.2, green: 0.15, blue: 0.1)
        }
    }
    
    var secondaryTextColor: Color {
        switch self {
        case .system: return Color(.secondaryLabel)
        case .light: return Color.gray
        case .dark: return Color(red: 0.7, green: 0.7, blue: 0.7)
        case .sepia: return Color(red: 0.4, green: 0.35, blue: 0.3)
        }
    }
}

// MARK: - User Settings Class

class UserSettings: ObservableObject {
    // MARK: - Published Properties
    
    @Published var fontSize: Double {
        didSet { saveSettings() }
    }
    
    @Published var fontFamily: FontFamily {
        didSet { saveSettings() }
    }
    
    @Published var lineSpacing: Double {
        didSet { saveSettings() }
    }
    
    @Published var backgroundTheme: BackgroundTheme {
        didSet { saveSettings() }
    }
    
    // MARK: - Initialization
    
    init() {
        self.fontSize = UserDefaults.standard.object(forKey: "fontSize") as? Double ?? 16.0
        self.fontFamily = FontFamily(rawValue: UserDefaults.standard.string(forKey: "fontFamily") ?? FontFamily.system.rawValue) ?? .system
        self.lineSpacing = UserDefaults.standard.object(forKey: "lineSpacing") as? Double ?? 6.0
        self.backgroundTheme = BackgroundTheme(rawValue: UserDefaults.standard.string(forKey: "backgroundTheme") ?? BackgroundTheme.system.rawValue) ?? .system
    }
    
    // MARK: - Methods
    
    private func saveSettings() {
        UserDefaults.standard.set(fontSize, forKey: "fontSize")
        UserDefaults.standard.set(fontFamily.rawValue, forKey: "fontFamily")
        UserDefaults.standard.set(lineSpacing, forKey: "lineSpacing")
        UserDefaults.standard.set(backgroundTheme.rawValue, forKey: "backgroundTheme")
    }
    
    func resetToDefaults() {
        fontSize = 16.0
        fontFamily = .system
        lineSpacing = 6.0
        backgroundTheme = .system
    }
    
    // MARK: - Computed Properties
    
    var dynamicFont: Font {
        switch fontFamily {
        case .system:
            return .system(size: fontSize)
        default:
            return .custom(fontFamily.rawValue, size: fontSize)
        }
    }
    
    var titleFont: Font {
        switch fontFamily {
        case .system:
            return .system(size: fontSize + 6, weight: .bold)
        default:
            return .custom(fontFamily.rawValue, size: fontSize + 6)
        }
    }
}

// MARK: - Theme Environment Modifier

struct ThemeModifier: ViewModifier {
    let userSettings: UserSettings
    @Environment(\.colorScheme) var systemColorScheme
    
    func body(content: Content) -> some View {
        content
            .preferredColorScheme(userSettings.backgroundTheme.colorScheme(for: systemColorScheme))
    }
}

extension View {
    func applyTheme(_ userSettings: UserSettings) -> some View {
        self.modifier(ThemeModifier(userSettings: userSettings))
    }
}

// MARK: - BackgroundTheme Extensions

extension BackgroundTheme {
    func colorScheme(for systemScheme: ColorScheme) -> ColorScheme? {
        switch self {
        case .system: return nil // Use system default
        case .light: return .light
        case .dark: return .dark
        case .sepia: return .light // Sepia uses light mode base
        }
    }
    
    var uiColor: UIColor {
        switch self {
        case .system: return UIColor.systemBackground
        case .light: return UIColor.white
        case .dark: return UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
        case .sepia: return UIColor(red: 0.97, green: 0.94, blue: 0.85, alpha: 1.0)
        }
    }
    
    var textUIColor: UIColor {
        switch self {
        case .system: return UIColor.label
        case .light: return UIColor.black
        case .dark: return UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        case .sepia: return UIColor(red: 0.2, green: 0.15, blue: 0.1, alpha: 1.0)
        }
    }
}
