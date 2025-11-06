//
//  TeacherStatisticsView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 31.10.2025.
//

import SwiftUI
import Charts

// MARK: - ChartData
struct ChartData: Identifiable {
    let id = UUID()
    let type: String
    let cost: Double
}

// MARK: - Enum для вибору типу діаграми
enum ChartType: String, CaseIterable, Identifiable {
    case bar = "Стовпчаста (Сума)"
    case pie = "Кругова (Частка)"
    var id: String { self.rawValue }
}

struct TeacherStatisticsView: View {
    let teacher: Teacher
    
    @State private var selectedDate = Date()
    @State private var selectedChartType: ChartType = .bar
    
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

                        Picker("Тип діаграми", selection: $selectedChartType) {
                            ForEach(ChartType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)

                        // Відображення діаграми відповідно до обраного типу
                        Group {
                            if selectedChartType == .bar {
                                LessonTypeBarChart(lessons: filteredLessons)
                            } else {
                                LessonTypePieChart(lessons: filteredLessons)
                            }
                        }
                        .frame(height: 250)
                        
                        Divider()
                    }
                } else {
                    ContentUnavailableView(
                        "Немає даних",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("Уроки за \(titleDateString) відсутні.")
                    )
                }
                
                LessonDetailedList(lessons: filteredLessons)
            }
            .navigationTitle("\(teacher.name) - Статистика")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Підсумок Статистики
struct StatisticsSummaryView: View {
    let lessons: [Lesson]
    
    var totalHours: Double {
        lessons.reduce(0.0) { $0 + $1.durationHours }
    }
    
    var totalUnpaid: Double {
        lessons.filter { !$0.isPaid }.reduce(0.0) { $0 + $1.cost }
    }
    
    var totalPaid: Double {
        lessons.filter { $0.isPaid }.reduce(0.0) { $0 + $1.cost }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
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
                Text(totalHours, format: .number.precision(.fractionLength(1)))
                    .bold()
                + Text(" год")
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }
}

// MARK: - Діаграма (Стовпчаста)
struct LessonTypeBarChart: View {
    let lessons: [Lesson]
    
    var data: [ChartData] {
        var grouped: [String: Double] = [:]
        for lesson in lessons {
            grouped[lesson.type.name, default: 0] += lesson.cost
        }
        return grouped.map { ChartData(type: $0.key, cost: $0.value) }
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

// MARK: - Діаграма (Кругова)
struct LessonTypePieChart: View {
    let lessons: [Lesson]
    
    var data: [ChartData] {
        var grouped: [String: Double] = [:]
        for lesson in lessons {
            grouped[lesson.type.name, default: 0] += lesson.cost
        }
        return grouped.map { ChartData(type: $0.key, cost: $0.value) }
    }
    
    var body: some View {
        Chart(data) { item in
            SectorMark(
                angle: .value("Вартість", item.cost),
                innerRadius: .ratio(0.618),
                angularInset: 1.5
            )
            .cornerRadius(5)
            .foregroundStyle(by: .value("Тип", item.type))
            .annotation(position: .overlay) {
                // Відсоток
                Text("\(item.cost / data.reduce(0.0, { $0 + $1.cost }), format: .percent.precision(.fractionLength(1)))")
                    .foregroundColor(.white)
                    .font(.caption)
            }
        }
        .chartLegend(position: .bottom, alignment: .center)
        .padding()
    }
}

// MARK: - Детальний Список
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
