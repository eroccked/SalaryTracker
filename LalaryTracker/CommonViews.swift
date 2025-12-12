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
        HStack(alignment: .top, spacing: 15) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.accentGreen.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "book.fill")
                    .foregroundColor(.accentGreen)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(lesson.type.name)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    Text(lesson.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    Text("\(lesson.durationHours, specifier: "%.1f") год")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(lesson.cost, format: .currency(code: "UAH"))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.accentGreen)
                
                Text("Ставка: \(lesson.rateApplied, specifier: "%.0f")")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}


// MARK: - MetricCard
struct MetricCard: View {
    let title: String
    let value: Double
    let unit: String
    let color: Color
    let icon: String
    
    init(title: String, value: Double, unit: String, color: Color, icon: String = "chart.bar.fill") {
        self.title = title
        self.value = value
        self.unit = unit
        self.color = color
        self.icon = icon
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
            
            Text(value, format: .currency(code: unit))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}

// MARK: - MonthPicker
struct MonthPicker: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        DatePicker("Період", selection: $selectedDate, displayedComponents: .date)
            .labelsHidden()
            .datePickerStyle(.compact)
            .tint(.accentGreen)
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
                .foregroundColor(.textPrimary)
                .padding(.horizontal)
            
            HStack {
                MetricCard(
                    title: "Загалом Зароблено",
                    value: totalCost,
                    unit: "UAH",
                    color: .accentGreen,
                    icon: "banknote.fill"
                )
            }
            .padding(.horizontal)
            
            HStack(spacing: 12) {
                Image(systemName: "timer")
                    .foregroundColor(.accentGreen)
                Text("Загальна кількість годин:")
                    .foregroundColor(.textSecondary)
                Spacer()
                Text("\(totalHours, specifier: "%.1f") год")
                    .bold()
                    .foregroundColor(.textPrimary)
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
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
        VStack(alignment: .leading, spacing: 12) {
            Text("Деталізація Уроків (\(lessons.count))")
                .font(.title2)
                .bold()
                .foregroundColor(.textPrimary)
                .padding(.horizontal)
                .padding(.top)

            VStack(spacing: 12) {
                ForEach(sortedLessons) { lesson in
                    LessonRow(lesson: lesson)
                        .padding(.horizontal)
                }
            }
        }
    }
}

// MARK: - PaymentRow
struct PaymentRow: View {
    let payment: Payment
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.accentGreen.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: payment.type.icon)
                    .foregroundColor(.accentGreen)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(payment.type.rawValue)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    Text(payment.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
                
                if !payment.note.isEmpty {
                    Text(payment.note)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(payment.amount, format: .currency(code: "UAH"))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.accentGreen)
                
                Text("ПЛАТІЖ")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}
