//
//  Theme.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 12.12.2025.
//
import SwiftUI

// MARK: - Color Palette
extension Color {
    // Бренд
    static let brandDeep  = Color(hex: "2E2FA3")        // Темні кнопки на світлому
    static let brand      = Color(hex: "5559E0")        // Основний акцент
    static let brandLight = Color(hex: "8C8FF0")

    // Текст
    static let ink          = Color(hex: "17172F")      // Основний текст
    static let inkSecondary = Color(hex: "8B8BA7")      // Підписи, дати

    // Поверхні
    static let surface     = Color.white
    static let surfaceSoft = Color(hex: "F5F4FA")       // Фон форм і вкладених карток
    static let hairline    = Color(hex: "ECEBF3")       // Розділювачі

    // Семантика
    static let positive = Color(hex: "3D9A74")          // Виплачено / отримано
    static let owed     = Color(hex: "E26D7D")          // Борг
    static let warm     = Color(hex: "E9A94A")

    // Кольори для графіків (по черзі для серій)
    static let chartPalette: [Color] = [
        Color(hex: "5559E0"),
        Color(hex: "F09A7A"),
        Color(hex: "4FAE8A"),
        Color(hex: "E9B44C"),
        Color(hex: "B07CE8"),
        Color(hex: "5FAEE3")
    ]

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

// MARK: - Gradients
enum AppGradient {
    static let background = LinearGradient(
        colors: [Color(hex: "3E41CF"), Color(hex: "6467E4"), Color(hex: "9D93EC"), Color(hex: "E3CFEF")],
        startPoint: .top,
        endPoint: .bottom
    )

    static let accent = LinearGradient(
        colors: [Color(hex: "7480F7"), Color(hex: "4B4FD8")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Пастельні плитки
    static let lavender = LinearGradient(colors: [Color(hex: "ECE6FC"), Color(hex: "F9E6F2")], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let peach    = LinearGradient(colors: [Color(hex: "FCE3D5"), Color(hex: "F8EFD9")], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let mint     = LinearGradient(colors: [Color(hex: "DBF2E9"), Color(hex: "F3F5DB")], startPoint: .topLeading, endPoint: .bottomTrailing)

    // Картка зі статистикою
    static let statCard = LinearGradient(colors: [Color(hex: "F9F2EC"), Color(hex: "F2F2EA")], startPoint: .leading, endPoint: .trailing)
}

// MARK: - Background
struct AppBackground: View {
    var body: some View {
        ZStack {
            AppGradient.background
            RadialGradient(
                colors: [Color(hex: "F6C3B5").opacity(0.7), .clear],
                center: .bottomTrailing,
                startRadius: 20,
                endRadius: 420
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Hero Scaffold
/// Градієнтна шапка зверху і біла панель із заокругленням, що «наїжджає» на неї.
struct HeroScaffold<Hero: View, Panel: View>: View {
    private let hero: Hero
    private let panel: Panel

    init(@ViewBuilder hero: () -> Hero, @ViewBuilder panel: () -> Panel) {
        self.hero = hero()
        self.panel = panel()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)

                VStack(alignment: .leading, spacing: 30) {
                    panel
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(alignment: .top) {
                    // Тягнемо білий фон нижче контенту, щоб короткі екрани не показували градієнт знизу
                    UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32, style: .continuous)
                        .fill(Color.surface)
                        .padding(.bottom, -1000)
                }
            }
        }
        .scrollIndicators(.hidden)
        .background(AppBackground())
    }
}

// MARK: - Button Styles

/// Біла «пігулка» на градієнті (як Send / Request)
struct PillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.subheadline, weight: .semibold))
            .foregroundStyle(Color.ink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.surface, in: Capsule())
            .shadow(color: .black.opacity(0.10), radius: 14, y: 6)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}

/// Темна компактна капсула (як Get Promo)
struct DarkCapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.subheadline, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 11)
            .background(Color.brandDeep, in: Capsule())
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

/// Головна дія у формах — градієнтна кнопка на всю ширину
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        PrimaryButtonBody(configuration: configuration)
    }

    private struct PrimaryButtonBody: View {
        let configuration: Configuration
        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            configuration.label
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(AppGradient.accent, in: Capsule())
                .shadow(color: Color.brand.opacity(isEnabled ? 0.35 : 0), radius: 12, y: 6)
                .opacity(isEnabled ? 1 : 0.45)
                .scaleEffect(configuration.isPressed ? 0.98 : 1)
                .animation(.spring(duration: 0.2), value: configuration.isPressed)
        }
    }
}

// MARK: - Form Styling
extension View {
    /// Спільний вигляд для всіх форм (додавання / редагування)
    func appFormStyle() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(Color.surfaceSoft)
            .tint(.brand)
    }

    /// Закріплена знизу головна кнопка форми
    func primaryAction(_ title: String, isDisabled: Bool = false, action: @escaping () -> Void) -> some View {
        safeAreaInset(edge: .bottom) {
            Button(title, action: action)
                .buttonStyle(PrimaryButtonStyle())
                .disabled(isDisabled)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .background(Color.surfaceSoft.opacity(0.95))
        }
    }
}
