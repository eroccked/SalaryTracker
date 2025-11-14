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
        let id = UUID()
        let payment: Payment
        let teacherName: String
    }

    var allPayments: [PaymentWithTeacher] {
        dataStore.teachers
            .flatMap { teacher in
                teacher.payments.map { payment in
                    PaymentWithTeacher(payment: payment, teacherName: teacher.name)
                }
            }
            .sorted { $0.payment.date > $1.payment.date }
    }
    
    var groupedPayments: [Date: [PaymentWithTeacher]] {
        let calendar = Calendar.current
        return Dictionary(grouping: allPayments) { paymentWithTeacher in
            calendar.date(from: calendar.dateComponents([.year, .month], from: paymentWithTeacher.payment.date))!
        }
    }
    
    var sortedGroupKeys: [Date] {
        groupedPayments.keys.sorted(by: >)
    }

    func monthSummary(for payments: [PaymentWithTeacher]) -> [PaymentType: Double] {
        payments.reduce(into: [PaymentType: Double]()) { result, paymentWithTeacher in
            result[paymentWithTeacher.payment.type, default: 0] += paymentWithTeacher.payment.amount
        }
    }
    
    var overallSummary: [PaymentType: Double] {
        allPayments.reduce(into: [PaymentType: Double]()) { result, paymentWithTeacher in
            result[paymentWithTeacher.payment.type, default: 0] += paymentWithTeacher.payment.amount
        }
    }
    
    var totalPayments: Double {
        overallSummary.values.reduce(0, +)
    }

    var body: some View {
        NavigationStack {
            List {
                // MARK: Загальний підсумок (Top Metrics)
                Section {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Всього Отримано (Загалом)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(totalPayments, format: .currency(code: "UAH"))
                                .font(.title2)
                                .fontWeight(.heavy)
                                .foregroundColor(.green)
                        }
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            if let cardTotal = overallSummary[.card], cardTotal > 0 {
                                HStack {
                                    Image(systemName: PaymentType.card.icon)
                                    Text(cardTotal, format: .currency(code: "UAH"))
                                }
                                .font(.callout)
                            }
                            if let cashTotal = overallSummary[.cash], cashTotal > 0 {
                                HStack {
                                    Image(systemName: PaymentType.cash.icon)
                                    Text(cashTotal, format: .currency(code: "UAH"))
                                }
                                .font(.callout)
                            }
                        }
                    }
                }
                
                // MARK: Історія транзакцій, згрупована по місяцях
                if allPayments.isEmpty {
                    ContentUnavailableView("Немає Транзакцій", systemImage: "banknote.fill", description: Text("Додайте перший платіж у деталях викладача."))
                }
                
                ForEach(sortedGroupKeys, id: \.self) { date in
                    Section {
                        ForEach(groupedPayments[date]!) { paymentWithTeacher in
                            PaymentRowWithTeacher(item: paymentWithTeacher)
                        }
                    } header: {
                        MonthHeaderView(date: date, summary: monthSummary(for: groupedPayments[date]!))
                    }
                }
                
            }
            .navigationTitle("Транзакції")
        }
    }
}

// MARK: - PaymentRowWithTeacher 
struct PaymentRowWithTeacher: View {
    let item: TransactionHistoryView.PaymentWithTeacher
    
    var body: some View {
        HStack {
            Image(systemName: item.payment.type.icon)
                .foregroundColor(.green)
            
            VStack(alignment: .leading) {
                Text(item.payment.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(item.teacherName)
                    .bold()
                
                if !item.payment.note.isEmpty {
                    Text(item.payment.note)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(item.payment.amount, format: .currency(code: "UAH"))
                    .font(.headline)
                    .foregroundColor(.green)
                
                Text(item.payment.type.rawValue)
                    .font(.caption)
            }
        }
    }
}

struct MonthHeaderView: View {
    let date: Date
    let summary: [PaymentType: Double]
    
    var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        formatter.locale = Locale(identifier: "uk_UA")
        return formatter.string(from: date).capitalized
    }
    
    var body: some View {
        HStack {
            Text(monthString)
            Spacer()
            if let cardTotal = summary[.card], cardTotal > 0 {
                Text("💳 \(cardTotal, format: .currency(code: "UAH"))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            if let cashTotal = summary[.cash], cashTotal > 0 {
                Text("💵 \(cashTotal, format: .currency(code: "UAH"))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
