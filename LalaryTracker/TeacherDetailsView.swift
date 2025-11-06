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
        
        let components = calendar.dateComponents([.year, .month], from: previousMonthDate)
        
        return teacher.lessons
            .filter { !$0.isPaid }
            .filter { lesson in
                let lessonComponents = calendar.dateComponents([.year, .month], from: lesson.date)
                return lessonComponents.year == components.year && lessonComponents.month == components.month
            }
            .reduce(0.0) { $0 + $1.cost }
    }
    
    // MARK: - Методи
    
    func deleteLesson(offsets: IndexSet) {
        teacher.lessons.remove(atOffsets: offsets)
        dataStore.saveTeachers() // Зберігаємо після видалення
    }
    
    func payPreviousMonthLessons() {
        let calendar = Calendar.current
        guard let previousMonthDate = calendar.date(byAdding: .month, value: -1, to: Date()) else { return }
        let components = calendar.dateComponents([.year, .month], from: previousMonthDate)
    
        for i in teacher.lessons.indices {
            let lesson = teacher.lessons[i]
            let lessonComponents = calendar.dateComponents([.year, .month], from: lesson.date)
            
            let isPreviousMonth = lessonComponents.year == components.year && lessonComponents.month == components.month
            
            if isPreviousMonth && !lesson.isPaid {

                teacher.lessons[i].isPaid = true
            }
        }
        dataStore.saveTeachers()
    }
    
    // MARK: - Body
    
    var body: some View {
        List {
            // MARK: Метрики
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
                
                HStack {
                    Image(systemName: "clock.fill")
                    Text("Неоплачено годин:")
                    Spacer()
                    
                    Text(calculateUnpaidHours, format: .number.precision(.fractionLength(1)))
                        .bold()
                        .foregroundColor(.accentColor)
                    Text("год")
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "calendar")
                        Text("Неоплачено за \(previousMonthName):")
                        Spacer()
                        Text(totalUnpaidSalaryForPreviousMonth, format: .currency(code: "UAH"))
                            .bold()
                            .foregroundColor(totalUnpaidSalaryForPreviousMonth > 0 ? .orange : .secondary)
                    }
                    .padding(.vertical, 4)
                    
                    if totalUnpaidSalaryForPreviousMonth > 0 {
                        Button {
                            payPreviousMonthLessons()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Відмітити всі уроки за \(previousMonthName) як оплачені")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                    }
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            
            // MARK: Історія Уроків
            Section("Історія Уроків") {
                if teacher.lessons.isEmpty {
                    ContentUnavailableView("Немає Уроків",
                                           systemImage: "list.clipboard",
                                           description: Text("Додайте перший урок, натиснувши '+' у верхньому куті."))
                }
                
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
}
