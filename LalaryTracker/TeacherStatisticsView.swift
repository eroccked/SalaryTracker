//
//  TeacherStatisticsView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 31.10.2025.
//  Updated with new design
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
    case bar = "Стовпчаста"
    case pie = "Кругова"
    var id: String { self.rawValue }
}

// MARK: - Enum для вибору періоду
enum PeriodType: String, CaseIterable, Identifiable {
    case month = "Місяць"
    case custom = "Довільний"
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
                                    .tint(.accentGreen)
                                    .padding(.horizontal)
                            } else {
                                VStack(spacing: 8) {
                                    HStack {
                                        Text("Від:")
                                            .foregroundColor(.textSecondary)
                                        DatePicker("", selection: $startDate, displayedComponents: .date)
                                            .labelsHidden()
                                            .tint(.accentGreen)
                                    }
                                    HStack {
                                        Text("До:")
                                            .foregroundColor(.textSecondary)
                                        DatePicker("", selection: $endDate, displayedComponents: .date)
                                            .labelsHidden()
                                            .tint(.accentGreen)
                                    }
                                }
                                .padding()
                                .background(Color.cardBackground)
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 10)
                        
                        // MARK: Підсумок періоду
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Підсумок за період")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.textPrimary)
                                .padding(.horizontal)
                            
                            HStack(spacing: 12) {
                                MetricCard(
                                    title: "Зароблено",
                                    value: filteredLessons.reduce(0) { $0 + $1.cost },
                                    unit: "UAH",
                                    color: .textPrimary,
                                    icon: "arrow.up.circle.fill"
                                )
                                
                                MetricCard(
                                    title: "Виплачено",
                                    value: totalPaidInPeriod,
                                    unit: "UAH",
                                    color: .accentGreen,
                                    icon: "checkmark.circle.fill"
                                )
                            }
                            .padding(.horizontal)
                            
                            HStack {
                                MetricCard(
                                    title: "Баланс за період",
                                    value: balanceForPeriod,
                                    unit: "UAH",
                                    color: balanceForPeriod > 0 ? .softRed : .accentGreen,
                                    icon: "chart.line.uptrend.xyaxis"
                                )
                            }
                            .padding(.horizontal)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "timer")
                                    .foregroundColor(.accentGreen)
                                Text("Загальна кількість годин:")
                                    .foregroundColor(.textSecondary)
                                Spacer()
                                Text("\(filteredLessons.reduce(0) { $0 + $1.durationHours }, specifier: "%.1f") год")
                                    .bold()
                                    .foregroundColor(.textPrimary)
                            }
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
                        // MARK: Діаграма
                        if !chartData.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Розподіл за типом уроків")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(.textPrimary)
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
                                        .background(Color.cardBackground)
                                        .cornerRadius(15)
                                        .padding(.horizontal)
                                } else {
                                    LessonTypePieChart(data: chartData)
                                        .frame(height: 300)
                                        .padding()
                                        .background(Color.cardBackground)
                                        .cornerRadius(15)
                                        .padding(.horizontal)
                                }
                            }
                        } else {
                            VStack(spacing: 20) {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.textSecondary)
                                
                                Text("Немає Даних")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.textPrimary)
                                
                                Text("Немає уроків у вибраний період")
                                    .font(.subheadline)
                                    .foregroundColor(.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        }
                        
                        // MARK: Деталізація платежів
                        if !filteredPayments.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Платежі (\(filteredPayments.count))")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(.textPrimary)
                                    .padding(.horizontal)
                                
                                ForEach(filteredPayments.sorted(by: { $0.date > $1.date })) { payment in
                                    PaymentRow(payment: payment)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        
                        // MARK: Деталізація уроків
                        LessonDetailedList(lessons: filteredLessons)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Статистика")
            .navigationBarTitleDisplayMode(.inline)
            .tint(.textPrimary)
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
            .foregroundStyle(Color.accentGreen.gradient)
            .cornerRadius(8)
            .annotation(position: .top, alignment: .center) {
                Text(item.cost, format: .currency(code: "UAH"))
                    .font(.caption2)
                    .foregroundColor(.textPrimary)
                    .padding(4)
                    .background(Color.cardBackground.opacity(0.8))
                    .cornerRadius(4)
            }
        }
        .chartXAxis {
            AxisMarks(position: .bottom) { value in
                AxisValueLabel()
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                    .foregroundStyle(Color.textSecondary.opacity(0.2))
                AxisValueLabel()
                    .foregroundStyle(Color.textSecondary)
            }
        }
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
                innerRadius: .ratio(0.5),
                outerRadius: .ratio(0.9),
                angularInset: 2.0
            )
            .cornerRadius(5)
            .foregroundStyle(by: .value("Тип", item.type))
            .annotation(position: .overlay) {
                if item.cost / totalCost > 0.1 {
                    Text("\((item.cost / totalCost), format: .percent.precision(.fractionLength(0)))")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.white)
                }
            }
        }
        .chartForegroundStyleScale([
            data[safe: 0]?.type ?? "": Color.accentGreen,
            data[safe: 1]?.type ?? "": Color.warmBrown,
            data[safe: 2]?.type ?? "": Color.textSecondary
        ])
        .chartLegend(position: .bottom, alignment: .center)
    }
}

// Helper extension for safe array access
extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
