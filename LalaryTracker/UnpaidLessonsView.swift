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
            VStack(spacing: 0) {
                // Date Picker Header
                HStack {
                    Text("Період:")
                        .font(.headline)
                    Spacer()
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Summary Section
                if !lessonsForSelectedMonth.isEmpty {
                    VStack(spacing: 12) {
                        HStack {
                            Text("Всього зароблено:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(totalEarnedForMonth, format: .currency(code: "UAH"))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        
                        HStack {
                            Image(systemName: "timer")
                            Text("Загальна кількість годин:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(totalHoursForMonth, specifier: "%.1f") год")
                                .bold()
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                }
                
                Divider()
                
                // Lessons List
                if lessonsForSelectedMonth.isEmpty {
                    ContentUnavailableView(
                        "Немає Уроків",
                        systemImage: "checkmark.circle.fill",
                        description: Text("Уроки за \(titleDateString) відсутні.")
                    )
                } else {
                    List {
                        ForEach(lessonsForSelectedMonth) { lesson in
                            if let teacherIndex = dataStore.teachers.firstIndex(where: { $0.lessons.contains(where: { $0.id == lesson.id }) }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(dataStore.teachers[teacherIndex].name)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    LessonRow(lesson: lesson)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Уроки за місяць")
        }
    }
}
