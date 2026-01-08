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
                        .padding()
                        .background(Color(.systemGray6))
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
                        .padding(.horizontal)
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Зароблено")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(filteredLessons.reduce(0) { $0 + $1.cost }, format: .currency(code: "UAH"))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Виплачено")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(totalPaidInPeriod, format: .currency(code: "UAH"))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Баланс за період")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(balanceForPeriod, format: .currency(code: "UAH"))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(balanceForPeriod > 0 ? .red : .green)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "timer")
                        Text("Загальна кількість годин:")
                        Spacer()
                        Text("\(filteredLessons.reduce(0) { $0 + $1.durationHours }, specifier: "%.1f") год")
                            .bold()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // MARK: Діаграма
                if !chartData.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Розподіл за типом уроків")
                            .font(.title3)
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
                        description: Text("Немає уроків у вибраний період")
                    )
                }
                
                // MARK: Деталізація платежів
                if !filteredPayments.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Платежі (\(filteredPayments.count))")
                            .font(.title3)
                            .bold()
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
        .navigationTitle("Статистика: \(titleDateString)")
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
