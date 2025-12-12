//
//  UnpaidLessonsView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 05.11.2025.
//  Updated with new design
//

import SwiftUI

struct UnpaidLessonsView: View {
    @EnvironmentObject var dataStore: DataStore
    
    @State private var selectedDate = Date()
    
    var titleDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        formatter.locale = Locale(identifier: "uk_UA")
        return formatter.string(from: selectedDate).capitalized
    }
    
    var lessonsForSelectedMonth: [Lesson] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: selectedDate)
        
        return dataStore.teachers
            .flatMap { $0.lessons }
            .filter { lesson in
                let lessonComponents = calendar.dateComponents([.year, .month], from: lesson.date)
                return lessonComponents.year == components.year && lessonComponents.month == components.month
            }
            .sorted(by: { $0.date > $1.date })
    }
    
    var totalEarnedForMonth: Double {
        lessonsForSelectedMonth.reduce(0) { $0 + $1.cost }
    }
    
    var totalHoursForMonth: Double {
        lessonsForSelectedMonth.reduce(0) { $0 + $1.durationHours }
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
                
                VStack(spacing: 0) {
                    // Date Picker Header
                    HStack {
                        Text("Період:")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        Spacer()
                        MonthPicker(selectedDate: $selectedDate)
                    }
                    .padding()
                    .background(Color.cardBackground)
                    
                    // Summary Section
                    if !lessonsForSelectedMonth.isEmpty {
                        VStack(spacing: 15) {
                            HStack(spacing: 12) {
                                MetricCard(
                                    title: "Всього зароблено",
                                    value: totalEarnedForMonth,
                                    unit: "UAH",
                                    color: .accentGreen,
                                    icon: "banknote.fill"
                                )
                            }
                            
                            HStack(spacing: 12) {
                                Image(systemName: "timer")
                                    .foregroundColor(.accentGreen)
                                Text("Загальна кількість годин:")
                                    .foregroundColor(.textSecondary)
                                Spacer()
                                Text("\(totalHoursForMonth, specifier: "%.1f") год")
                                    .bold()
                                    .foregroundColor(.textPrimary)
                            }
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(12)
                        }
                        .padding()
                        .background(Color.white.opacity(0.3))
                    }
                    
                    // Lessons List
                    ScrollView {
                        if lessonsForSelectedMonth.isEmpty {
                            VStack(spacing: 20) {
                                Spacer()
                                    .frame(height: 100)
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.accentGreen)
                                
                                Text("Немає Уроків")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.textPrimary)
                                
                                Text("Уроки за \(titleDateString) відсутні")
                                    .font(.subheadline)
                                    .foregroundColor(.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                        } else {
                            VStack(spacing: 12) {
                                ForEach(lessonsForSelectedMonth) { lesson in
                                    if let teacherIndex = dataStore.teachers.firstIndex(where: { $0.lessons.contains(where: { $0.id == lesson.id }) }) {
                                        VStack(spacing: 0) {
                                            // Teacher name badge
                                            HStack {
                                                Image(systemName: "person.fill")
                                                    .font(.caption)
                                                    .foregroundColor(.textSecondary)
                                                Text(dataStore.teachers[teacherIndex].name)
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.textSecondary)
                                                Spacer()
                                            }
                                            .padding(.horizontal)
                                            .padding(.top, 8)
                                            
                                            LessonRow(lesson: lesson)
                                                .padding(.horizontal)
                                                .padding(.bottom, 8)
                                        }
                                    }
                                }
                            }
                            .padding(.top, 20)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .navigationTitle("Уроки за місяць")
            .tint(.textPrimary)
        }
    }
}
