//
//  UnpaidLessonsView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 05.11.2025.
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
    
    var unpaidLessonsForSelectedMonth: [Lesson] {
        return lessonsForSelectedMonth
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Text("Період:")
                    Spacer()
                    MonthPicker(selectedDate: $selectedDate)
                }
                .padding()
                
                Divider()
                
                if unpaidLessonsForSelectedMonth.isEmpty {
                    ContentUnavailableView(
                        "Немає Уроків",
                        systemImage: "hand.thumbsup.fill",
                        description: Text("Уроки за \(titleDateString) відсутні.")
                    )
                } else {
                    List {
                        ForEach(unpaidLessonsForSelectedMonth) { lesson in
                            if let teacherIndex = dataStore.teachers.firstIndex(where: { $0.lessons.contains(where: { $0.id == lesson.id }) }),
                                let lessonIndex = dataStore.teachers[teacherIndex].lessons.firstIndex(where: { $0.id == lesson.id })
                            {
                                LessonRow(lesson: lesson)
                                    .overlay(
                                        Text(dataStore.teachers[teacherIndex].name)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                            .offset(y: -20),
                                        alignment: .topLeading
                                    )
                            }
                        }
                    }
                }
            }
            .navigationTitle("💸 Уроки за місяць")
        }
    }
}
