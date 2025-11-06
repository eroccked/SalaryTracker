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
