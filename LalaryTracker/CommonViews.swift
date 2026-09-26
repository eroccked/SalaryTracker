//
//  CommonViews.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 06.11.2025.
//
import SwiftUI
import Charts

// MARK: - SectionHeader
struct SectionHeader: View {
    let title: String
    var trailing: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(Color.ink)

            Spacer()

            if let trailing {
                if let action {
                    Button(trailing, action: action)
                        .font(.subheadline)
                        .foregroundStyle(Color.inkSecondary)
                } else {
                    Text(trailing)
                        .font(.subheadline)
                        .foregroundStyle(Color.inkSecondary)
                }
            }
        }
    }
}

// MARK: - AvatarView
/// Кружок з ініціалами на пастельному фоні. Колір стабільний для кожного імені.
struct AvatarView: View {
    let name: String
    var size: CGFloat = 48

    private static let palette: [(background: String, foreground: String)] = [
        ("ECE6FC", "5559E0"),
        ("FCE3D5", "C0663F"),
        ("DBF2E9", "2F8A66"),
        ("FBE6EF", "C24C73"),
        ("FFF0D0", "A8740F"),
        ("E1EFFB", "3A78B5")
    ]

    private var initials: String {
        let parts = name.split(separator: " ").prefix(2)
        let letters = parts.compactMap { $0.first }.map { String($0) }.joined()
        return letters.isEmpty ? "?" : letters.uppercased()
    }

    private var colors: (background: Color, foreground: Color) {
        let sum = name.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        let pair = Self.palette[sum % Self.palette.count]
        return (Color(hex: pair.background), Color(hex: pair.foreground))
    }

    var body: some View {
        Text(initials)
            .font(.system(size: size * 0.36, weight: .semibold, design: .rounded))
            .foregroundStyle(colors.foreground)
            .frame(width: size, height: size)
            .background(colors.background, in: Circle())
    }
}

// MARK: - IconBadge
struct IconBadge: View {
    let systemName: String
    var tint: Color = .brand
    var size: CGFloat = 48

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size * 0.38, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(tint.opacity(0.12), in: Circle())
    }
}

// MARK: - ListRow
/// Рядок списку: аватар/іконка, назва з підписом, сума з підписом.
struct ListRow<Leading: View>: View {
    let title: String
    let subtitle: String
    let value: String
    var valueColor: Color = .ink
    let caption: String
    var showsDivider: Bool = true
    private let leading: Leading

    init(
        title: String,
        subtitle: String,
        value: String,
        valueColor: Color = .ink,
        caption: String,
        showsDivider: Bool = true,
        @ViewBuilder leading: () -> Leading
    ) {
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.valueColor = valueColor
        self.caption = caption
        self.showsDivider = showsDivider
        self.leading = leading()
    }

    var body: some View {
        HStack(spacing: 14) {
            leading

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(.body, weight: .semibold))
                    .foregroundStyle(Color.ink)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.inkSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 3) {
                Text(value)
                    .font(.system(.body, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(valueColor)
                    .lineLimit(1)
                Text(caption)
                    .font(.subheadline)
                    .foregroundStyle(Color.inkSecondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 14)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) {
            if showsDivider {
                Rectangle()
                    .fill(Color.hairline)
                    .frame(height: 1)
            }
        }
    }
}

// MARK: - QuickActionTile
struct QuickActionTile: View {
    let title: String
    let icon: String
    let background: LinearGradient
    var tint: Color = .brand
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 52, height: 52)
                    .background(Color.surface, in: Circle())
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 4)

                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(Color.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - MonthSwitcher
struct MonthSwitcher: View {
    enum Style { case onGradient, onSurface }

    @Binding var date: Date
    var style: Style = .onGradient

    private var foreground: Color { style == .onGradient ? .white : .ink }
    private var background: Color { style == .onGradient ? .white.opacity(0.18) : .surfaceSoft }

    var body: some View {
        HStack(spacing: 4) {
            arrow("chevron.left") { date = date.addingMonths(-1) }

            Text(Fmt.month(date))
                .font(.system(.subheadline, weight: .semibold))
                .foregroundStyle(foreground)
                .frame(minWidth: 120)
                .contentTransition(.numericText())

            arrow("chevron.right") { date = date.addingMonths(1) }
        }
        .padding(4)
        .background(background, in: Capsule())
    }

    private func arrow(_ name: String, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.snappy) { action() }
        } label: {
            Image(systemName: name)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(foreground)
                .frame(width: 32, height: 32)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - HeroAmount
/// Велика сума в шапці з підписом над нею
struct HeroAmount: View {
    let caption: String
    let amount: Double

    var body: some View {
        VStack(spacing: 8) {
            Text(caption)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.78))

            Text(Fmt.money(amount))
                .font(.system(size: 46, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .contentTransition(.numericText())
        }
    }
}

// MARK: - HeroTitle
struct HeroTitle: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.brand)
                .frame(width: 28, height: 28)
                .background(.white, in: Circle())
            Text(title)
                .font(.title2.bold())
                .foregroundStyle(.white)
        }
        .padding(.top, 8)
    }
}

// MARK: - InfoStrip
/// Напівпрозора смужка з повідомленням (як «New promo!»)
struct InfoStrip: View {
    let icon: String
    let text: String
    var buttonTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.brand)
                .frame(width: 34, height: 34)
                .background(Color.surface, in: Circle())

            Text(text)
                .font(.system(.subheadline, weight: .medium))
                .foregroundStyle(Color.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 8)

            if let buttonTitle, let action {
                Button(buttonTitle, action: action)
                    .buttonStyle(DarkCapsuleButtonStyle())
            }
        }
        .padding(10)
        .padding(.leading, 2)
        .background(.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

// MARK: - HeroChip
/// Маленька напівпрозора плашка на градієнті (годин / уроків)
struct HeroChip: View {
    let icon: String
    let text: String

    var body: some View {
        Label(text, systemImage: icon)
            .font(.system(.footnote, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(.white.opacity(0.18), in: Capsule())
    }
}

// MARK: - DonutStatCard
struct DonutEntry: Identifiable {
    var id: String { label }
    let label: String
    let value: Double
    let color: Color
}

struct DonutStatCard: View {
    let entries: [DonutEntry]

    private var total: Double { entries.reduce(0) { $0 + max($1.value, 0) } }

    var body: some View {
        HStack(spacing: 22) {
            ZStack {
                Circle()
                    .stroke(Color.hairline, lineWidth: 12)
                    .padding(6)

                if total > 0 {
                    Chart(entries) { entry in
                        SectorMark(
                            angle: .value("Сума", max(entry.value, 0)),
                            innerRadius: .ratio(0.7),
                            angularInset: 2
                        )
                        .cornerRadius(4)
                        .foregroundStyle(entry.color)
                    }
                    .chartLegend(.hidden)
                }
            }
            .frame(width: 88, height: 88)

            LazyVGrid(
                columns: [GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading)],
                alignment: .leading,
                spacing: 14
            ) {
                ForEach(entries) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(entry.color)
                                .frame(width: 8, height: 8)
                            Text(entry.label)
                                .font(.subheadline)
                                .foregroundStyle(Color.ink.opacity(0.75))
                                .lineLimit(1)
                        }
                        Text(Fmt.money(entry.value))
                            .font(.system(.title3, design: .rounded, weight: .semibold))
                            .foregroundStyle(Color.ink)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppGradient.statCard, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}

// MARK: - SummaryRow
/// Рядок «назва — значення» у м'якій картці
struct SummaryRow: View {
    let title: String
    let value: String
    var valueColor: Color = .ink

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(Color.inkSecondary)
            Spacer()
            Text(value)
                .font(.system(.body, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(valueColor)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(Color.surfaceSoft, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

// MARK: - EmptyStateView
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(Color.brand)
                .frame(width: 64, height: 64)
                .background(Color.brand.opacity(0.1), in: Circle())
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.ink)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color.inkSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
    }
}

// MARK: - Rows
struct LessonListRow: View {
    let lesson: Lesson
    var showsDivider: Bool = true

    var body: some View {
        ListRow(
            title: lesson.type.name,
            subtitle: "\(Fmt.day(lesson.date)) · \(Fmt.hours(lesson.durationHours))",
            value: Fmt.money(lesson.cost),
            caption: "\(Fmt.money(lesson.rateApplied))/год",
            showsDivider: showsDivider
        ) {
            IconBadge(systemName: "book.closed.fill", tint: .brand)
        }
    }
}

struct PaymentListRow: View {
    let payment: Payment
    var showsDivider: Bool = true

    private var subtitle: String {
        payment.note.isEmpty ? Fmt.day(payment.date) : "\(Fmt.day(payment.date)) · \(payment.note)"
    }

    var body: some View {
        ListRow(
            title: payment.type.rawValue,
            subtitle: subtitle,
            value: Fmt.signedMoney(payment.amount),
            valueColor: .positive,
            caption: "Виплата",
            showsDivider: showsDivider
        ) {
            IconBadge(systemName: payment.type.icon, tint: .positive)
        }
    }
}
