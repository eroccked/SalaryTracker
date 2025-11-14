//
//  CommonViews.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 06.11.2025.
//

import SwiftUI

// MARK: - LessonRow
struct LessonRow: View {
    let lesson: Lesson
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(lesson.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(lesson.type.name)
                    .bold()
                + Text(" (\(lesson.durationHours, specifier: "%.1f") год)")
                    .font(.callout)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("Ставка: \(lesson.rateApplied, specifier: "%.2f")")
                    .font(.caption)
                
                Text(lesson.cost, format: .currency(code: "UAH"))
                    .foregroundColor(.blue)
                    .bold()

            }
        }
    }
}


// MARK: - MetricCard
struct MetricCard: View {
    let title: String
    let value: Double
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(alignment: .lastTextBaseline) {
                Text(value, format: .currency(code: unit))
                    .font(.title2)
                    .fontWeight(.heavy)
                    .foregroundColor(color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

// MARK: - MonthPicker
struct MonthPicker: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        DatePicker("Період", selection: $selectedDate, displayedComponents: .date)
            .labelsHidden()
            .datePickerStyle(.compact)
    }
}

// MARK: - StatisticsSummaryView
struct StatisticsSummaryView: View {
    let lessons: [Lesson]
    
    var totalCost: Double {
        lessons.reduce(0) { $0 + $1.cost }
    }
    
    var totalHours: Double {
        lessons.reduce(0) { $0 + $1.durationHours }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Місячний Підсумок")
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            HStack {
                MetricCard(title: "Загалом Зароблено", value: totalCost, unit: "UAH", color: .blue)
            }
            .padding(.horizontal)
            
            HStack {
                Image(systemName: "timer")
                Text("Загальна кількість годин:")
                Spacer()
                Text("\(totalHours, specifier: "%.1f") год")
                    .bold()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }
}

// MARK: - LessonDetailedList
struct LessonDetailedList: View {
    let lessons: [Lesson]
    
    var sortedLessons: [Lesson] {
        lessons.sorted(by: { $0.date > $1.date })
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Деталізація Уроків (\(lessons.count))")
                .font(.title2)
                .bold()
                .padding(.horizontal)
                .padding(.top)

            VStack(spacing: 0) {
                ForEach(sortedLessons) { lesson in
                    LessonRow(lesson: lesson)
                        .padding(.horizontal)
                    Divider()
                }
            }
        }
    }
}
// MARK: - PaymentRow
struct PaymentRow: View {
    let payment: Payment
    
    var body: some View {
        HStack {
            Image(systemName: payment.type.icon)
                .foregroundColor(.green)
            
            VStack(alignment: .leading) {
                Text(payment.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(payment.note.isEmpty ? payment.type.rawValue : payment.note)
                    .bold()
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("ПЛАТІЖ")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                
                Text(payment.amount, format: .currency(code: "UAH"))
                    .font(.callout)
                    .foregroundColor(.green)
                    .bold()
            }
        }
    }
}
