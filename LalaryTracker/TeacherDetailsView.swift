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
    
    var filteredPayments: [Payment] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: selectedDate)
        
        return teacher.payments.filter { payment in
            let paymentComponents = calendar.dateComponents([.year, .month], from: payment.date)
            return paymentComponents.year == components.year && paymentComponents.month == components.month
        }.sorted(by: { $0.date > $1.date })
    }
    
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
    
    // MARK: - Body View
    
    var body: some View {
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
                    
                    // MARK: Загальний Баланс
                    VStack(spacing: 15) {
                        Text("Загальна Статистика")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 12) {
                            MetricCard(
                                title: "Загальний Баланс",
                                value: teacher.currentBalance,
                                unit: "UAH",
                                color: teacher.currentBalance > 0 ? .softRed : .accentGreen,
                                icon: "chart.line.uptrend.xyaxis"
                            )
                            
                            MetricCard(
                                title: "Всього Виплачено",
                                value: teacher.totalPaid,
                                unit: "UAH",
                                color: .accentGreen,
                                icon: "checkmark.circle.fill"
                            )
                        }
                        
                        HStack(spacing: 12) {
                            Image(systemName: "banknote.fill")
                                .foregroundColor(.accentGreen)
                            Text("Всього заробленo:")
                                .foregroundColor(.textSecondary)
                            Spacer()
                            Text(teacher.totalEarned, format: .currency(code: "UAH"))
                                .bold()
                                .foregroundColor(.textPrimary)
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // MARK: Місячний Баланс
                    VStack(spacing: 15) {
                        HStack {
                            Text("Місячний Баланс")
                                .font(.headline)
                                .foregroundColor(.textPrimary)
                            
                            Spacer()
                            
                            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                .labelsHidden()
                                .datePickerStyle(.compact)
                                .tint(.accentGreen)
                        }
                        
                        VStack(spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Зароблено за \(monthString)")
                                        .font(.caption)
                                        .foregroundColor(.textSecondary)
                                    Text(monthlyEarned, format: .currency(code: "UAH"))
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.textPrimary)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(12)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Виплачено за \(monthString)")
                                        .font(.caption)
                                        .foregroundColor(.textSecondary)
                                    Text(monthlyPaid, format: .currency(code: "UAH"))
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.accentGreen)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(12)
                            
                            Divider()
                                .padding(.vertical, 4)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Баланс за \(monthString)")
                                        .font(.subheadline)
                                        .foregroundColor(.textSecondary)
                                    Text(monthlyBalance, format: .currency(code: "UAH"))
                                        .font(.title)
                                        .fontWeight(.heavy)
                                        .foregroundColor(monthlyBalance > 0 ? .softRed : .accentGreen)
                                }
                                
                                Spacer()
                                
                                if monthlyBalance > 0 {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.title2)
                                        .foregroundColor(.softRed)
                                } else if monthlyBalance < 0 {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.accentGreen)
                                }
                            }
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: monthlyBalance > 0 ?
                                        [Color.softRed.opacity(0.1), Color.softRed.opacity(0.15)] :
                                        [Color.accentGreen.opacity(0.05), Color.accentGreen.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(monthlyBalance > 0 ? Color.softRed.opacity(0.3) : Color.accentGreen.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .padding()
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    
                    // MARK: Платежі
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Платежі за \(monthString) (\(filteredPayments.count))")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal)
                        
                        if filteredPayments.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "tray.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.textSecondary)
                                Text("Платежів у цей місяць немає")
                                    .foregroundColor(.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            ForEach(filteredPayments) { payment in
                                if let index = teacher.payments.firstIndex(where: { $0.id == payment.id }) {
                                    NavigationLink {
                                        EditPaymentView(payment: $teacher.payments[index])
                                            .environmentObject(dataStore)
                                    } label: {
                                        PaymentRow(payment: payment)
                                            .padding(.horizontal)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            withAnimation {
                                                teacher.payments.remove(at: index)
                                                dataStore.saveTeachers()
                                            }
                                        } label: {
                                            Label("Видалити", systemImage: "trash.fill")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // MARK: Уроки
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Уроки (\(teacher.lessons.count))")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal)
                        
                        if teacher.lessons.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "book.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.textSecondary)
                                Text("Уроків ще немає. Додайте перший урок!")
                                    .foregroundColor(.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            ForEach(sortedLessons) { lesson in
                                if let index = teacher.lessons.firstIndex(where: { $0.id == lesson.id }) {
                                    NavigationLink {
                                        EditLessonView(lesson: $teacher.lessons[index])
                                            .environmentObject(dataStore)
                                    } label: {
                                        LessonRow(lesson: lesson)
                                            .padding(.horizontal)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            withAnimation {
                                                teacher.lessons.remove(at: index)
                                                dataStore.saveTeachers()
                                            }
                                        } label: {
                                            Label("Видалити", systemImage: "trash.fill")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationTitle(teacher.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.light, for: .navigationBar)
        .tint(.textPrimary)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingAddLessonSheet = true
                    } label: {
                        Label("Додати Урок", systemImage: "book.fill")
                    }
                    
                    Button {
                        showingAddPaymentSheet = true
                    } label: {
                        Label("Додати Платіж", systemImage: "banknote.fill")
                    }
                    
                    Button {
                        showingStatsSheet = true
                    } label: {
                        Label("Статистика", systemImage: "chart.bar.xaxis")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.title3)
                        .foregroundColor(.accentGreen)
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
