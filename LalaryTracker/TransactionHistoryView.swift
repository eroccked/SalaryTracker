//
//  TransactionHistoryView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 14.11.2025.
//

import SwiftUI

struct TransactionHistoryView: View {
    @EnvironmentObject var dataStore: DataStore

    struct PaymentWithTeacher: Identifiable {
        var id: UUID { payment.id }
        let payment: Payment
        let teacherName: String
    }

    var allPayments: [PaymentWithTeacher] {
        dataStore.teachers
            .flatMap { teacher in
                teacher.payments.map { PaymentWithTeacher(payment: $0, teacherName: teacher.name) }
            }
            .sorted { $0.payment.date > $1.payment.date }
    }

    var groupedPayments: [Date: [PaymentWithTeacher]] {
        let calendar = Calendar.current
        return Dictionary(grouping: allPayments) { item in
            calendar.date(from: calendar.dateComponents([.year, .month], from: item.payment.date))!
        }
    }

    var sortedGroupKeys: [Date] {
        groupedPayments.keys.sorted(by: >)
    }

    var overallSummary: [PaymentType: Double] {
        allPayments.reduce(into: [PaymentType: Double]()) { result, item in
            result[item.payment.type, default: 0] += item.payment.amount
        }
    }

    var totalPayments: Double {
        overallSummary.values.reduce(0, +)
    }

    private var donutEntries: [DonutEntry] {
        let colors: [PaymentType: Color] = [.card: .brand, .cash: Color(hex: "E9A94A"), .other: Color(hex: "F09A7A")]
        return PaymentType.allCases.compactMap { type in
            let value = overallSummary[type] ?? 0
            // «Інше» показуємо лише якщо воно є
            if type == .other && value == 0 { return nil }
            return DonutEntry(label: type.rawValue, value: value, color: colors[type] ?? .brand)
        }
    }

    var body: some View {
        NavigationStack {
            HeroScaffold {
                VStack(spacing: 22) {
                    HeroTitle(title: "Транзакції", icon: "wallet.bifold.fill")

                    HeroAmount(caption: "Всього виплачено", amount: totalPayments)
                        .padding(.top, 10)

                    HeroChip(icon: "arrow.left.arrow.right", text: "\(allPayments.count) платежів")
                }
            } panel: {
                if allPayments.isEmpty {
                    EmptyStateView(
                        icon: "banknote.fill",
                        title: "Немає транзакцій",
                        message: "Додайте перший платіж на сторінці викладача\nабо через «+» внизу."
                    )
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Статистика")
                        DonutStatCard(entries: donutEntries)
                    }

                    ForEach(sortedGroupKeys, id: \.self) { date in
                        let payments = groupedPayments[date] ?? []
                        VStack(alignment: .leading, spacing: 4) {
                            SectionHeader(
                                title: Fmt.month(date),
                                trailing: Fmt.money(payments.reduce(0) { $0 + $1.payment.amount })
                            )

                            ForEach(payments) { item in
                                PaymentRowWithTeacher(item: item, showsDivider: item.id != payments.last?.id)
                            }
                        }
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - PaymentRowWithTeacher
struct PaymentRowWithTeacher: View {
    let item: TransactionHistoryView.PaymentWithTeacher
    var showsDivider: Bool = true

    private var subtitle: String {
        item.payment.note.isEmpty
            ? Fmt.day(item.payment.date)
            : "\(Fmt.day(item.payment.date)) · \(item.payment.note)"
    }

    var body: some View {
        ListRow(
            title: item.teacherName,
            subtitle: subtitle,
            value: Fmt.signedMoney(item.payment.amount),
            caption: item.payment.type.rawValue,
            showsDivider: showsDivider
        ) {
            AvatarView(name: item.teacherName)
        }
    }
}
