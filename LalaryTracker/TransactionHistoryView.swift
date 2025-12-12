//
//  TransactionHistoryView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 14.11.2025.
//  Updated with new design
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
            ZStack {
                // Gradient Background
                LinearGradient(
                    colors: [
                        Color(hex: "B8E6E1"),
                        Color(hex: "A8DDD8"),
                        Color(hex: "B8E6E1")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // MARK: Загальний підсумок (Top Metrics)
                        VStack(spacing: 15) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Всього Отримано")
                                        .font(.subheadline)
                                        .foregroundColor(.textSecondary)
                                    Text(totalPayments, format: .currency(code: "UAH"))
                                        .font(.system(size: 36, weight: .heavy))
                                        .foregroundColor(.accentGreen)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                            
                            HStack(spacing: 12) {
                                if let cardTotal = overallSummary[.card], cardTotal > 0 {
                                    HStack {
                                        Image(systemName: PaymentType.card.icon)
                                            .foregroundColor(.accentGreen)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Картка")
                                                .font(.caption)
                                                .foregroundColor(.textSecondary)
                                            Text(cardTotal, format: .currency(code: "UAH"))
                                                .font(.headline)
                                                .foregroundColor(.textPrimary)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.cardBackground)
                                    .cornerRadius(12)
                                }
                                
                                if let cashTotal = overallSummary[.cash], cashTotal > 0 {
                                    HStack {
                                        Image(systemName: PaymentType.cash.icon)
                                            .foregroundColor(.accentGreen)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Готівка")
                                                .font(.caption)
                                                .foregroundColor(.textSecondary)
                                            Text(cashTotal, format: .currency(code: "UAH"))
                                                .font(.headline)
                                                .foregroundColor(.textPrimary)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.cardBackground)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        // MARK: Історія транзакцій, згрупована по місяцях
                        if allPayments.isEmpty {
                            VStack(spacing: 20) {
                                Spacer()
                                    .frame(height: 80)
                                
                                Image(systemName: "banknote.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.textSecondary)
                                
                                Text("Немає Транзакцій")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.textPrimary)
                                
                                Text("Додайте перший платіж у деталях викладача")
                                    .font(.subheadline)
                                    .foregroundColor(.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                        } else {
                            ForEach(sortedGroupKeys, id: \.self) { date in
                                VStack(alignment: .leading, spacing: 12) {
                                    MonthHeaderView(date: date, summary: monthSummary(for: groupedPayments[date]!))
                                        .padding(.horizontal)
                                    
                                    ForEach(groupedPayments[date]!) { paymentWithTeacher in
                                        PaymentRowWithTeacher(item: paymentWithTeacher)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Транзакції")
            .tint(.textPrimary)
        }
    }
}

// MARK: - PaymentRowWithTeacher 
struct PaymentRowWithTeacher: View {
    let item: TransactionHistoryView.PaymentWithTeacher
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.accentGreen.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: item.payment.type.icon)
                    .foregroundColor(.accentGreen)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(item.teacherName)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    Text(item.payment.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
                
                if !item.payment.note.isEmpty {
                    Text(item.payment.note)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: item.payment.type.icon)
                        .font(.caption2)
                    Text(item.payment.type.rawValue)
                        .font(.caption)
                }
                .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(item.payment.amount, format: .currency(code: "UAH"))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.accentGreen)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
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
    
    var totalAmount: Double {
        summary.values.reduce(0, +)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(monthString)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                HStack(spacing: 12) {
                    if let cardTotal = summary[.card], cardTotal > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: PaymentType.card.icon)
                                .font(.caption)
                            Text(cardTotal, format: .currency(code: "UAH"))
                                .font(.caption)
                        }
                        .foregroundColor(.textSecondary)
                    }
                    if let cashTotal = summary[.cash], cashTotal > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: PaymentType.cash.icon)
                                .font(.caption)
                            Text(cashTotal, format: .currency(code: "UAH"))
                                .font(.caption)
                        }
                        .foregroundColor(.textSecondary)
                    }
                }
            }
            
            Spacer()
            
            Text(totalAmount, format: .currency(code: "UAH"))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.accentGreen)
        }
        .padding()
        .background(Color.white.opacity(0.3))
        .cornerRadius(12)
    }
}
