//
//  TeacherDetailsView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 30.10.2025.
//

import SwiftUI

struct TeacherDetailsView: View {
    @Binding var teacher: Teacher
    
    @State private var showingAddLessonSheet = false
    
    var body: some View {
        List {
            Section("Статистика Зарплати") {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Неоплачено годин:")
                        Text("Неоплачена сума:")
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("\(calculateUnpaidHours(), specifier: "%.1f") год")
                            .bold()
                        Text(teacher.totalUnpaidSalary, format: .currency(code: "UAH"))
                            .foregroundColor(teacher.totalUnpaidSalary > 0 ? .red : .secondary)
                            .bold()
                    }
                }
                
                HStack {
                    Text("Всього виплачено:")
                    Spacer()
                    Text(teacher.totalPaidSalary, format: .currency(code: "UAH"))
                        .foregroundColor(.green)
                }
            }
            
            Section("Уроки (\(teacher.lessons.count))") {
                if teacher.lessons.isEmpty {
                    Text("Уроків ще немає. Додайте перший урок!")
                        .foregroundColor(.gray)
                } else {
                    ForEach(teacher.lessons.sorted(by: { $0.date > $1.date })) { lesson in
                        LessonRow(lesson: lesson)
                    }
                    .onDelete(perform: deleteLesson)
                }
            }
        }
        .navigationTitle(teacher.name)
        .toolbar {
            Button {
                showingAddLessonSheet = true
            } label: {
                Label("Додати Урок", systemImage: "plus.circle.fill")
            }
        }
        .sheet(isPresented: $showingAddLessonSheet) {
            AddLessonView(teacherLessons: $teacher.lessons)
        }
    }
    
    func calculateUnpaidHours() -> Double {
        return teacher.lessons.filter { !$0.isPaid }.reduce(0.0) { $0 + $1.durationHours }
    }
    
    func deleteLesson(offsets: IndexSet) {
        let sortedLessons = teacher.lessons.sorted(by: { $0.date > $1.date })
        let lessonsToDelete = offsets.map { sortedLessons[$0].id }
        
        teacher.lessons.removeAll { lessonsToDelete.contains($0.id) }
    }
}



struct LessonRow: View {
    let lesson: Lesson
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(lesson.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(lesson.type ?? "Урок")
                    .bold()
                + Text(" (\(lesson.durationHours, specifier: "%.1f") год)")
                    .font(.callout)
            }
            
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
