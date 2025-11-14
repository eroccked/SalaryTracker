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

// MARK: - Enum для вибору періоду
enum PeriodType: String, CaseIterable, Identifiable {
    case month = "Місяць"
    case custom = "Довільний період"
    var id: String { self.rawValue }
}

struct TeacherStatisticsView: View {
    let teacher: Teacher
    
    @State private var selectedDate = Date()
    @State private var selectedChartType: ChartType = .bar
    @State private var periodType: PeriodType = .month
    
    @State private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate = Date()
    
    var titleDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        formatter.locale = Locale(identifier: "uk_UA")
        
        if periodType == .month {
            return formatter.string(from: selectedDate).capitalized
        } else {
            let shortFormatter = DateFormatter()
            shortFormatter.dateFormat = "dd.MM.yy"
            return "\(shortFormatter.string(from: startDate)) - \(shortFormatter.string(from: endDate))"
        }
    }
    
    var filteredLessons: [Lesson] {
        let calendar = Calendar.current
        
        if periodType == .month {
            let components = calendar.dateComponents([.year, .month], from: selectedDate)
            
            return teacher.lessons.filter { lesson in
                let lessonComponents = calendar.dateComponents([.year, .month], from: lesson.date)
                return lessonComponents.year == components.year && lessonComponents.month == components.month
            }
        } else {
            return teacher.lessons.filter { lesson in
                lesson.date >= startDate && lesson.date <= endDate
            }
        }
    }
    
    var filteredPayments: [Payment] {
        let calendar = Calendar.current
        
        if periodType == .month {
            let components = calendar.dateComponents([.year, .month], from: selectedDate)
            
            return teacher.payments.filter { payment in
                let paymentComponents = calendar.dateComponents([.year, .month], from: payment.date)
                return paymentComponents.year == components.year && paymentComponents.month == components.month
            }
        } else {
            return teacher.payments.filter { payment in
                payment.date >= startDate && payment.date <= endDate
            }
        }
    }
    
    var totalPaidInPeriod: Double {
        filteredPayments.reduce(0) { $0 + $1.amount }
    }
    
    var balanceForPeriod: Double {
        let earned = filteredLessons.reduce(0) { $0 + $1.cost }
        return earned - totalPaidInPeriod
    }
    
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
                
                // MARK: Вибір періоду
                VStack(spacing: 12) {
                    Picker("Тип періоду", selection: $periodType) {
                        ForEach(PeriodType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    if periodType == .month {
                        DatePicker("Місяць", selection: $selectedDate, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.compact)
                            .padding(.horizontal)
                    } else {
                        VStack(spacing: 8) {
                            HStack {
                                Text("Від:")
                                DatePicker("", selection: $startDate, displayedComponents: .date)
                                    .labelsHidden()
                            }
                            HStack {
                                Text("До:")
                                DatePicker("", selection: $endDate, displayedComponents: .date)
                                    .labelsHidden()
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // MARK: Підсумок періоду
                VStack(alignment: .leading, spacing: 15) {
                    Text("Підсумок за період")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    HStack {
                        MetricCard(
                            title: "Зароблено",
                            value: filteredLessons.reduce(0) { $0 + $1.cost },
                            unit: "UAH",
                            color: .blue
                        )
                        
                        MetricCard(
                            title: "Виплачено",
                            value: totalPaidInPeriod,
                            unit: "UAH",
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        MetricCard(
                            title: "Баланс за період",
                            value: balanceForPeriod,
                            unit: "UAH",
                            color: balanceForPeriod > 0 ? .red : .green
                        )
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Image(systemName: "timer")
                        Text("Загальна кількість годин:")
                        Spacer()
                        Text("\(filteredLessons.reduce(0) { $0 + $1.durationHours }, specifier: "%.1f") год")
                            .bold()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
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
                    ContentUnavailableView(
                        "Немає Даних",
                        systemImage: "chart.bar.fill",
                        description: Text("Немає уроків у вибраний період.")
                    )
                }
                
                // MARK: Деталізація
                if !filteredPayments.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Платежі (\(filteredPayments.count))")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                            .padding(.top)
                        
                        VStack(spacing: 0) {
                            ForEach(filteredPayments.sorted(by: { $0.date > $1.date })) { payment in
                                PaymentRow(payment: payment)
                                    .padding(.horizontal)
                                Divider()
                            }
                        }
                    }
                }
                
                LessonDetailedList(lessons: filteredLessons)
            }
            .navigationTitle("Статистика: \(titleDateString)")
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
