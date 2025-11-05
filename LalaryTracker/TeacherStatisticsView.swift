//
//  TeacherStatisticsView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 31.10.2025.
//

import SwiftUI
import Charts

struct TeacherStatisticsView: View {
    let teacher: Teacher
    
    @State private var selectedDate = Date()
    
    var titleDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        formatter.locale = Locale(identifier: "uk_UA")
        return formatter.string(from: selectedDate).capitalized
    }
    
    var filteredLessons: [Lesson] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: selectedDate)
        
        return teacher.lessons.filter { lesson in
            let lessonComponents = calendar.dateComponents([.year, .month], from: lesson.date)
            return lessonComponents.year == components.year && lessonComponents.month == components.month
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text("Період:")
                    Spacer()
                    
                    MonthPicker(selectedDate: $selectedDate)
                }
                .padding(.horizontal)

                Divider()

                StatisticsSummaryView(lessons: filteredLessons)
                
                Divider()

                if !filteredLessons.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Виплати за типом уроку:")
                            .font(.headline)
                            .padding(.leading)

                        LessonTypeChart(lessons: filteredLessons)
                            .frame(height: 250)
                            .padding()
                    }
                } else {
                    Text("Немає уроків за вибраний період.")
                        .foregroundColor(.gray)
                        .padding()
                }

                LessonDetailedList(lessons: filteredLessons)
            }
        }
        .navigationTitle("Статистика за \(titleDateString)")
    }
}

struct MonthPicker: View {
    @Binding var selectedDate: Date
    private let calendar = Calendar.current
    
    var body: some View {
        HStack(spacing: 15) {
            Button {
                changeMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .imageScale(.large)
            }
            
            Text(selectedDate, format: .dateTime.month(.wide).year())
                .font(.headline)
                .frame(minWidth: 120)
            
            Button {
                changeMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .imageScale(.large)
            }
        }
    }
    
    func changeMonth(by amount: Int) {
        if let newDate = calendar.date(byAdding: .month, value: amount, to: selectedDate) {
            selectedDate = newDate
        }
    }
}


struct StatisticsSummaryView: View {
    let lessons: [Lesson]
    
    var totalUnpaid: Double {
        lessons.filter { !$0.isPaid }.reduce(0) { $0 + $1.cost }
    }
    
    var totalPaid: Double {
        lessons.filter { $0.isPaid }.reduce(0) { $0 + $1.cost }
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
                MetricCard(title: "До виплати", value: totalUnpaid, unit: "UAH", color: .red)
                MetricCard(title: "Всього оплачено", value: totalPaid, unit: "UAH", color: .green)
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
struct LessonTypeChart: View {
    let lessons: [Lesson]
    
    var data: [ChartData] {
        let grouped = lessons.reduce(into: [String: Double]()) { result, lesson in
            result[lesson.type.name, default: 0.0] += lesson.cost
        }
        return grouped.map { ChartData(type: $0.key, cost: $0.value) }
    }
    
    struct ChartData: Identifiable {
        let id = UUID()
        let type: String
        let cost: Double
    }
    
    var body: some View {
        Chart(data) { item in
            BarMark(
                x: .value("Тип Уроку", item.type),
                y: .value("Вартість (грн)", item.cost)
            )
            .annotation(position: .overlay, alignment: .top) {
                Text(item.cost, format: .currency(code: "UAH"))
                    .font(.caption2)
                    .foregroundColor(.black)
            }
            .foregroundStyle(by: .value("Тип", item.type))
        }
        .chartYAxisLabel("Сума (грн)")
        .chartXAxisLabel("Тип Уроку")
        .padding(.horizontal)
    }
}


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

// MARK: - Спільні Компоненти

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
                    .font(.callout)            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("Ставка: \(lesson.rateApplied, specifier: "%.2f")")
                    .font(.caption)
                
                Text(lesson.cost, format: .currency(code: "UAH"))
                    .foregroundColor(lesson.isPaid ? .green : .red)
                    .bold()
                
                Text(lesson.isPaid ? "✅ Оплачено" : "❌ Не оплачено")
                    .font(.caption2)
            }
        }
    }
}

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
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
