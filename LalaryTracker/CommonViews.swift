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
                // Дата уроку
                Text(lesson.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Тип та тривалість уроку
                Text(lesson.type.name)
                    .bold()
                + Text(" (\(lesson.durationHours, format: .number.precision(.fractionLength(1))) год)")
                    .font(.callout)            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                // Застосована ставка
                HStack(spacing: 0) {
                    Text("Ставка: ")
                        .font(.caption)
                    Text(lesson.rateApplied, format: .number.precision(.fractionLength(2)))
                        .font(.caption)
                }
                
                // Вартість уроку
                Text(lesson.cost, format: .currency(code: "UAH"))
                    .foregroundColor(lesson.isPaid ? .green : .red)
                    .bold()
                
                Text(lesson.isPaid ? "✅ Оплачено" : "❌ Не оплачено")
                    .font(.caption2)
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
