//
//  TeacherStatisticsView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 31.10.2025.
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
    
    // Обчислення даних для діаграм
    var chartData: [ChartData] {
        Dictionary(grouping: filteredLessons, by: { $0.type.name })
            .map { (key, lessons) in
                ChartData(type: key, cost: lessons.reduce(0) { $0 + $1.cost })
            }
            .sorted { $0.cost > $1.cost }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                MonthPicker(selectedDate: $selectedDate)
                    .padding(.horizontal)
                
                StatisticsSummaryView(lessons: filteredLessons)
                    .padding(.horizontal)
                
                // MARK: Діаграма
                if !chartData.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Розподіл за типом уроків")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                        
                        Picker("Тип діаграми", selection: $selectedChartType) {
                            ForEach(ChartType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        
                        // Діаграма
                        if selectedChartType == .bar {
                            LessonTypeBarChart(data: chartData)
                                .frame(height: 250)
                                .padding()
                        } else {
                            LessonTypePieChart(data: chartData)
                                .frame(height: 300)
                                .padding()
                        }
                    }
                } else {
                    ContentUnavailableView("Немає Даних", systemImage: "chart.bar.fill", description: Text("Немає уроків у вибраний місяць."))
                }
                
                LessonDetailedList(lessons: filteredLessons)
            }
            .navigationTitle("Статистика \(titleDateString)")
        }
    }
}

// MARK: - ДОПОМІЖНІ VIEW

struct LessonTypeBarChart: View {
    let data: [ChartData]
    
    var body: some View {
        Chart(data) { item in
            BarMark(
                x: .value("Тип", item.type),
                y: .value("Сума, UAH", item.cost)
            )
            .annotation(position: .overlay, alignment: .top) {
                Text(item.cost, format: .currency(code: "UAH"))
                    .font(.caption2)
                    .foregroundColor(.white)
            }
        }
        .chartForegroundStyleScale(domain: data.map { $0.type })
    }
}

struct LessonTypePieChart: View {
    let data: [ChartData]
    
    var totalCost: Double {
        data.reduce(0) { $0 + $1.cost }
    }
    
    var body: some View {
        Chart(data) { item in
            SectorMark(
                angle: .value("Сума", item.cost),
                innerRadius: 50,
                outerRadius: 120,
                angularInset: 1.0
            )
            .cornerRadius(5)
            .foregroundStyle(by: .value("Тип", item.type))
            .annotation(position: .overlay) {
                Text("\((item.cost / totalCost), format: .percent.precision(.fractionLength(1)))")
                    .font(.caption)
                    .bold()
            }
        }
        .chartLegend(position: .bottom, alignment: .center)
    }
}
