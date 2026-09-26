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
    var id: String { type }
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

    @Environment(\.dismiss) var dismiss

    @State private var selectedDate = Date()
    @State private var selectedChartType: ChartType = .bar
    @State private var periodType: PeriodType = .month

    @State private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate = Date()

    var filteredLessons: [Lesson] {
        if periodType == .month {
            return teacher.lessons.filter { $0.date.isSameMonth(as: selectedDate) }
        } else {
            return teacher.lessons.filter { $0.date >= startDate && $0.date <= endDate }
        }
    }

    var filteredPayments: [Payment] {
        if periodType == .month {
            return teacher.payments.filter { $0.date.isSameMonth(as: selectedDate) }
        } else {
            return teacher.payments.filter { $0.date >= startDate && $0.date <= endDate }
        }
    }

    var totalEarnedInPeriod: Double {
        filteredLessons.reduce(0) { $0 + $1.cost }
    }

    var totalPaidInPeriod: Double {
        filteredPayments.reduce(0) { $0 + $1.amount }
    }

    var balanceForPeriod: Double {
        totalEarnedInPeriod - totalPaidInPeriod
    }

    var totalHours: Double {
        filteredLessons.reduce(0) { $0 + $1.durationHours }
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
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    periodPicker
                    summary
                    chartSection
                    paymentsSection
                    lessonsSection
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
            .background(Color.surface)
            .navigationTitle("Статистика")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                }
            }
            .tint(.brand)
        }
    }

    // MARK: - Вибір періоду

    private var periodPicker: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                AvatarView(name: teacher.name, size: 40)
                Text(teacher.name)
                    .font(.headline)
                    .foregroundStyle(Color.ink)
                Spacer()
            }

            Picker("Тип періоду", selection: $periodType) {
                ForEach(PeriodType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)

            if periodType == .month {
                MonthSwitcher(date: $selectedDate, style: .onSurface)
            } else {
                VStack(spacing: 0) {
                    DatePicker("Від", selection: $startDate, displayedComponents: .date)
                        .padding(.vertical, 8)
                    Rectangle().fill(Color.hairline).frame(height: 1)
                    DatePicker("До", selection: $endDate, displayedComponents: .date)
                        .padding(.vertical, 8)
                }
                .padding(.horizontal, 16)
                .background(Color.surfaceSoft, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
    }

    // MARK: - Підсумок періоду

    private var summary: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Підсумок")

            DonutStatCard(entries: [
                DonutEntry(label: "Зароблено", value: totalEarnedInPeriod, color: .brand),
                DonutEntry(label: "Виплачено", value: totalPaidInPeriod, color: .positive)
            ])

            VStack(spacing: 10) {
                SummaryRow(
                    title: "Баланс за період",
                    value: Fmt.money(balanceForPeriod),
                    valueColor: balanceForPeriod > 0 ? .owed : .positive
                )
                SummaryRow(title: "Години", value: Fmt.hours(totalHours))
                SummaryRow(title: "Уроки", value: "\(filteredLessons.count)")
            }
        }
    }

    // MARK: - Діаграма

    @ViewBuilder
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "За типами уроків")

            if chartData.isEmpty {
                EmptyStateView(
                    icon: "chart.bar.fill",
                    title: "Немає даних",
                    message: "Немає уроків у вибраний період"
                )
            } else {
                Picker("Тип діаграми", selection: $selectedChartType) {
                    ForEach(ChartType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)

                Group {
                    if selectedChartType == .bar {
                        LessonTypeBarChart(data: chartData)
                            .frame(height: 240)
                    } else {
                        LessonTypePieChart(data: chartData)
                            .frame(height: 280)
                    }
                }
                .padding(18)
                .background(Color.surfaceSoft, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            }
        }
    }

    // MARK: - Деталізація

    @ViewBuilder
    private var paymentsSection: some View {
        if !filteredPayments.isEmpty {
            let payments = filteredPayments.sorted(by: { $0.date > $1.date })
            VStack(alignment: .leading, spacing: 4) {
                SectionHeader(title: "Платежі", trailing: "\(payments.count)")
                ForEach(payments) { payment in
                    PaymentListRow(payment: payment, showsDivider: payment.id != payments.last?.id)
                }
            }
        }
    }

    @ViewBuilder
    private var lessonsSection: some View {
        if !filteredLessons.isEmpty {
            let lessons = filteredLessons.sorted(by: { $0.date > $1.date })
            VStack(alignment: .leading, spacing: 4) {
                SectionHeader(title: "Уроки", trailing: "\(lessons.count)")
                ForEach(lessons) { lesson in
                    LessonListRow(lesson: lesson, showsDivider: lesson.id != lessons.last?.id)
                }
            }
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
                y: .value("Сума", item.cost),
                width: .ratio(0.55)
            )
            .cornerRadius(10)
            .foregroundStyle(by: .value("Тип", item.type))
            .annotation(position: .top, spacing: 6) {
                Text(Fmt.money(item.cost))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color.ink)
            }
        }
        .chartForegroundStyleScale(domain: data.map(\.type), range: Array(Color.chartPalette.prefix(max(data.count, 1))))
        .chartLegend(.hidden)
        .chartYAxis {
            AxisMarks { _ in
                AxisGridLine().foregroundStyle(Color.hairline)
                AxisValueLabel().foregroundStyle(Color.inkSecondary)
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel().foregroundStyle(Color.ink)
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
                innerRadius: .ratio(0.55),
                angularInset: 2
            )
            .cornerRadius(6)
            .foregroundStyle(by: .value("Тип", item.type))
            .annotation(position: .overlay) {
                Text((item.cost / totalCost), format: .percent.precision(.fractionLength(0)))
                    .font(.caption.bold())
                    .foregroundStyle(.white)
            }
        }
        .chartForegroundStyleScale(domain: data.map(\.type), range: Array(Color.chartPalette.prefix(max(data.count, 1))))
        .chartLegend(position: .bottom, alignment: .center)
    }
}
