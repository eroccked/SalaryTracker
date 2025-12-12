//
//  Theme.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 12.12.2025.
//
import SwiftUI

// MARK: - Color Palette
extension Color {
    static let appBackground = Color(hex: "B8E6E1")      // М'ятно-бірюзовий фон
    static let cardBackground = Color(hex: "E8F4F2")     // Світлий м'ятний для карток
    static let textPrimary = Color(hex: "000000")        // Чорний для основного тексту та іконок
    static let textSecondary = Color(hex: "6B7280")      // Темно-сірий для вторинного тексту
    static let accentGreen = Color(hex: "000000")        // Чорний для акцентів та іконок
    static let warmBrown = Color(hex: "6B7280")          // Темно-сірий
    static let softRed = Color(hex: "D98B8B")            // М'який пастельний червоний для боргів
    
    // Hex initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Custom Styles
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.cardBackground)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct LargeCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
    
    func largeCardStyle() -> some View {
        modifier(LargeCardModifier())
    }
}

// MARK: - Custom Button Style
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentGreen)
            .cornerRadius(15)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .shadow(color: Color.accentGreen.opacity(0.3), radius: 5, x: 0, y: 3)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.textPrimary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(15)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
    }
}
