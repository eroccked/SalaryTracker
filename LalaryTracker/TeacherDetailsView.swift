//
//  TeacherDetailsView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 30.10.2025.
//

import SwiftUI

struct TeacherDetailsView: View {
    @Binding var teacher: Teacher
    @EnvironmentObject var dataStore: DataStore
    
    @State private var showingAddLessonSheet = false
    @State private var showingStatsSheet = false
    
    // MARK: - Обчислювальні Властивості
    
    var sortedLessons: [Lesson] {
        teacher.lessons.sorted(by: { $0.date > $1.date })
    }
    
    var calculateUnpaidHours: Double {
        let unpaidLessons = teacher.lessons.filter { !$0.isPaid }
        return unpaidLessons.reduce(0.0) { sum, lesson in sum + lesson.durationHours }
    }
    
    var previousMonthName: String {
        let calendar = Calendar.current
        guard let previousMonthDate = calendar.date(byAdding: .month, value: -1, to: Date()) else { return "попередній місяць" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        formatter.locale = Locale(identifier: "uk_UA")
        return formatter.string(from: previousMonthDate).capitalized
    }
    
    var totalUnpaidSalaryForPreviousMonth: Double {
        let calendar = Calendar.current
        guard let previousMonthDate = calendar.date(byAdding: .month, value: -1, to: Date()) else { return 0 }
        
        let previousMonthComponents = calendar.dateComponents([.year, .month], from: previousMonthDate)
        
        return teacher.lessons
            .filter { lesson in
                let lessonComponents = calendar.dateComponents([.year, .month], from: lesson.date)
                return lessonComponents.year == previousMonthComponents.year && lessonComponents.month == previousMonthComponents.month
            }
            .filter { !$0.isPaid }
            .reduce(0) { $0 + $1.cost }
    }
    
    // MARK: - Функції
    
    func markPreviousMonthLessonsAsPaid() {
        let calendar = Calendar.current
        guard let previousMonthDate = calendar.date(byAdding: .month, value: -1, to: Date()) else { return }
        
        let previousMonthComponents = calendar.dateComponents([.year, .month], from: previousMonthDate)
        
        for index in teacher.lessons.indices {
            let lesson = teacher.lessons[index]
            let lessonComponents = calendar.dateComponents([.year, .month], from: lesson.date)
            
            if lessonComponents.year == previousMonthComponents.year &&
                lessonComponents.month == previousMonthComponents.month &&
                !lesson.isPaid {
                
                teacher.lessons[index].isPaid = true
            }
        }
    }
    
    func deleteLesson(offsets: IndexSet) {
        let lessonsToDelete = offsets.map { sortedLessons[$0].id }
        teacher.lessons.removeAll { lessonsToDelete.contains($0.id) }
    }
    
    // MARK: - Body View
    
    var body: some View {
        List {
            Section {
                HStack {
                    MetricCard(
                        title: "Неоплачено",
                        value: teacher.totalUnpaidSalary,
                        unit: "UAH",
                        color: .red
                    )
                    
                    MetricCard(
                        title: "Всього Виплачено",
                        value: teacher.totalPaidSalary,
                        unit: "UAH",
                        color: .green
                    )
                }
                
                if totalUnpaidSalaryForPreviousMonth > 0 {
                    Button {
                        markPreviousMonthLessonsAsPaid()
                    } label: {
                        HStack {
                            Text("Мені заплатили \(totalUnpaidSalaryForPreviousMonth, format: .currency(code: "UAH")) за \(previousMonthName)")
                                .bold()
                            Spacer()
                            Image(systemName: "banknote.fill")
                        }
                    }
                    .foregroundColor(.white)
                    .listRowBackground(Color.accentColor)
                }
                
                HStack {
                    Image(systemName: "clock.fill")
                    Text("Неоплачено годин:")
                    Spacer()
                    Text("\(calculateUnpaidHours, specifier: "%.1f")")
                        .bold()
                        .foregroundColor(.accentColor)
                    Text("год")
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            
            Section("Уроки (\(teacher.lessons.count))") {
                if teacher.lessons.isEmpty {
                    Text("Уроків ще немає. Додайте перший урок!")
                        .foregroundColor(.gray)
                } else {
                    
                    ForEach(sortedLessons) { lesson in
                        
                        if let index = teacher.lessons.firstIndex(where: { $0.id == lesson.id }) {
                            
                            NavigationLink {
                                EditLessonView(lesson: $teacher.lessons[index])
                                    .environmentObject(dataStore)
                            } label: {
                                LessonRow(lesson: lesson)
                            }
                        }
                    }
                    .onDelete(perform: deleteLesson)
                }
            }
        }
        .navigationTitle(teacher.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingStatsSheet = true
                } label: {
                    Label("Статистика", systemImage: "chart.bar.xaxis")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddLessonSheet = true
                } label: {
                    Label("Додати Урок", systemImage: "plus.circle.fill")
                }
            }
        }
        .sheet(isPresented: $showingAddLessonSheet) {
            AddLessonView(teacherLessons: $teacher.lessons)
                .environmentObject(dataStore)
        }
        
        .sheet(isPresented: $showingStatsSheet) {
            TeacherStatisticsView(teacher: teacher)
                .environmentObject(dataStore)
        }
    }
    
    // MARK: - LessonRow
    
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
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
}
