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
    @State private var showingAddPaymentSheet = false
    
    // MARK: - Обчислювальні Властивості
    
    var sortedLessons: [Lesson] {
        teacher.lessons.sorted(by: { $0.date > $1.date })
    }
    
    var sortedPayments: [Payment] {
            teacher.payments.sorted(by: { $0.date > $1.date })
        }
    
    var previousMonthName: String {
        let calendar = Calendar.current
        guard let previousMonthDate = calendar.date(byAdding: .month, value: -1, to: Date()) else { return "попередній місяць" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        formatter.locale = Locale(identifier: "uk_UA")
        return formatter.string(from: previousMonthDate).capitalized
    }
    
    // MARK: - Функції
    
    
    func deleteLesson(offsets: IndexSet) {
        let lessonsToDelete = offsets.map { sortedLessons[$0].id }
        teacher.lessons.removeAll { lessonsToDelete.contains($0.id) }
        dataStore.saveTeachers()
    }
    
    func deletePayment(offsets: IndexSet) {
            let paymentsToDelete = offsets.map { sortedPayments[$0].id }
            teacher.payments.removeAll { paymentsToDelete.contains($0.id) }
            dataStore.saveTeachers()
        }
    
    // MARK: - Body View
    
    var body: some View {
        List {
            Section {
                HStack {
                    MetricCard(
                        title: "Баланс (Заборгованість)",
                        value: teacher.currentBalance,
                        unit: "UAH",
                        color: teacher.currentBalance < 0 ? .red : .blue
                    )
                    
                    MetricCard(
                        title: "Всього Виплачено",
                        value: teacher.totalPaid,
                        unit: "UAH",
                        color: .green
                    )
                }
                
                
                HStack {
                    Image(systemName: "banknote.fill")
                    Text("Всього зароблено:")
                    Spacer()
                    Text(teacher.totalEarned, format: .currency(code: "UAH"))
                        .bold()
                        .foregroundColor(.accentColor)
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            
            Section("Платежі (\(teacher.payments.count))") {
                            if teacher.payments.isEmpty {
                                Text("Платежів ще немає.")
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(sortedPayments) { payment in
                                    PaymentRow(payment: payment)
                                }
                                .onDelete(perform: deletePayment)
                            }
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
                                showingAddPaymentSheet = true
                            } label: {
                                Label("Додати Платіж", systemImage: "plus.forwardslash.minus")
                            }
                        }
            
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
        .sheet(isPresented: $showingAddPaymentSheet) {
                    AddPaymentView(teacher: $teacher)
                        .environmentObject(dataStore)
        }
    }
}
