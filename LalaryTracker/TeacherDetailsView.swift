//
//  TeacherDetailsView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 30.10.2025.
//


import SwiftUI

struct TeacherDetailsView: View {
    @Binding var teacher: Teacher
    @EnvironmentObject var dataStore: DataStore
    
    @State private var showingAddLessonSheet = false
    @State private var showingStatsSheet = false
    @State private var showingAddPaymentSheet = false
    @State private var selectedDate = Date()
    
    // MARK: - Обчислювальні Властивості
    
    var sortedLessons: [Lesson] {
        teacher.lessons.sorted(by: { $0.date > $1.date })
    }
    
    var sortedPayments: [Payment] {
        teacher.payments.sorted(by: { $0.date > $1.date })
    }
    
    // Платежі за обраний місяць
    var filteredPayments: [Payment] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: selectedDate)
        
        return teacher.payments.filter { payment in
            let paymentComponents = calendar.dateComponents([.year, .month], from: payment.date)
            return paymentComponents.year == components.year && paymentComponents.month == components.month
        }.sorted(by: { $0.date > $1.date })
    }
    
    // Місячні дані
    var monthlyEarned: Double {
        teacher.totalEarned(for: selectedDate)
    }
    
    var monthlyPaid: Double {
        teacher.totalPayments(for: selectedDate)
    }
    
    var monthlyBalance: Double {
        monthlyEarned - monthlyPaid
    }
    
    var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        formatter.locale = Locale(identifier: "uk_UA")
        return formatter.string(from: selectedDate).capitalized
    }
    
    // MARK: - Функції
    
    func deleteLesson(offsets: IndexSet) {
        let lessonsToDelete = offsets.map { sortedLessons[$0].id }
        teacher.lessons.removeAll { lessonsToDelete.contains($0.id) }
        dataStore.saveTeachers()
    }
    
    func deletePayment(offsets: IndexSet) {
        let paymentsToDelete = offsets.map { filteredPayments[$0].id }
        teacher.payments.removeAll { paymentsToDelete.contains($0.id) }
        dataStore.saveTeachers()
    }
    
    // MARK: - Body View
    
    var body: some View {
        List {
            // MARK: Загальний Баланс
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 2) { // 4 * 0.67 ≈ 2
                        Text("Загальний Баланс")
                            .font(.system(size: 9.3)) // caption ≈ 11pt, 11 * 0.67 ≈ 7.3
                            .foregroundColor(.secondary)
                        Text(teacher.currentBalance, format: .currency(code: "UAH"))
                            .font(.system(size: 13.3, weight: .bold)) // title2 ≈ 20pt, 20 * 0.67 ≈ 13.3
                            .foregroundColor(teacher.currentBalance > 0 ? .red : .green)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Всього Виплачено")
                            .font(.system(size: 9.3))
                            .foregroundColor(.secondary)
                        Text(teacher.totalPaid, format: .currency(code: "UAH"))
                            .font(.system(size: 11.3, weight: .semibold)) // title3 ≈ 17pt, 17 * 0.67 ≈ 11.3
                            .foregroundColor(.green)
                    }
                }
                
                HStack {
                    Text("Всього зароблено:")
                        .font(.system(size: 9.3)) // body ≈ 14pt, 14 * 0.67 ≈ 9.3
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(teacher.totalEarned, format: .currency(code: "UAH"))
                        .font(.system(size: 9.3, weight: .bold))
                }
            }
            
            // MARK: Місячний Баланс
            Section {
                DatePicker("Період", selection: $selectedDate, displayedComponents: .date)
                    .font(.system(size: 9.3)) // 14 * 0.67 ≈ 9.3
                
                HStack {
                    Text("Зароблено за місяць:")
                        .font(.system(size: 13.3))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(monthlyEarned, format: .currency(code: "UAH"))
                        .font(.system(size: 13.3, weight: .semibold))
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Text("Виплачено за місяць:")
                        .font(.system(size: 13.3))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(monthlyPaid, format: .currency(code: "UAH"))
                        .font(.system(size: 13.3, weight: .semibold))
                        .foregroundColor(.green)
                }
                
                HStack {
                    Text("Баланс за \(monthString):")
                        .font(.system(size: 13.3))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(monthlyBalance, format: .currency(code: "UAH"))
                        .font(.system(size: 13.3, weight: .bold)) // headline ≈ 17pt, 17 * 0.67 ≈ 11.3
                        .foregroundColor(monthlyBalance > 0 ? .red : .green)
                }
            } header: {
                Text("Місячна Статистика")
                    .font(.system(size: 11.3))
            }
            
            // MARK: Платежі
            Section("Платежі за \(monthString) (\(filteredPayments.count))") {
                if filteredPayments.isEmpty {
                    Text("Платежів у цей місяць немає.")
                        .font(.system(size: 11.3))
                        .foregroundColor(.gray)
                } else {
                    ForEach(filteredPayments) { payment in
                        if let index = teacher.payments.firstIndex(where: { $0.id == payment.id }) {
                            NavigationLink {
                                EditPaymentView(payment: $teacher.payments[index])
                                    .environmentObject(dataStore)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(payment.date, style: .date)
                                            .font(.system(size: 11.3)) // subheadline
                                            .foregroundColor(.secondary)
                                        if !payment.note.isEmpty {
                                            Text(payment.note)
                                                .font(.system(size: 7.3)) // caption
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text(payment.amount, format: .currency(code: "UAH"))
                                            .font(.system(size: 11.3, weight: .bold))
                                            .foregroundColor(.green)
                                        Text(payment.type.rawValue)
                                            .font(.system(size: 7.3))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    .onDelete(perform: deletePayment)
                }
            }
            
            // MARK: Уроки
            Section("Уроки (\(teacher.lessons.count))") {
                if teacher.lessons.isEmpty {
                    Text("Уроків ще немає. Додайте перший урок!")
                        .font(.system(size: 9.3))
                        .foregroundColor(.gray)
                } else {
                    ForEach(sortedLessons) { lesson in
                        if let index = teacher.lessons.firstIndex(where: { $0.id == lesson.id }) {
                            NavigationLink {
                                EditLessonView(lesson: $teacher.lessons[index])
                                    .environmentObject(dataStore)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(lesson.date, style: .date)
                                            .font(.system(size: 11.3))
                                            .foregroundColor(.secondary)

                                        Text(lesson.type.name)
                                            .font(.system(size: 11.3, weight: .bold))
                                        + Text(" (\(lesson.durationHours, specifier: "%.1f") год)")
                                            .font(.system(size: 9.3))
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        Text("Ставка: \(lesson.rateApplied, specifier: "%.2f")")
                                            .font(.system(size: 11.3))
                                        
                                        Text(lesson.cost, format: .currency(code: "UAH"))
                                            .font(.system(size: 11.3, weight: .bold))
                                            .foregroundColor(.blue)
                                    }
                                }
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
