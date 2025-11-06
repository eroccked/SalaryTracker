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
    
    var unpaidLessonsForSelectedMonth: [Lesson] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: selectedDate)
        
        return dataStore.teachers
            .flatMap { $0.lessons }
            .filter { !$0.isPaid }
            .filter { lesson in
                let lessonComponents = calendar.dateComponents([.year, .month], from: lesson.date)
                return lessonComponents.year == components.year && lessonComponents.month == components.month
            }
            .sorted(by: { $0.date > $1.date })
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
                        "Неоплачених уроків немає",
                        systemImage: "hand.thumbsup.fill",
                        description: Text("Всі уроки за \(titleDateString) оплачено.")
                    )
                } else {
                    List {
                        ForEach(unpaidLessonsForSelectedMonth) { lesson in
                            if let teacherIndex = dataStore.teachers.firstIndex(where: { $0.lessons.contains(where: { $0.id == lesson.id }) }),
                               let lessonIndex = dataStore.teachers[teacherIndex].lessons.firstIndex(where: { $0.id == lesson.id })
                            {
                                UnpaidLessonRow(
                                    teacherName: dataStore.teachers[teacherIndex].name,
                                    lesson: $dataStore.teachers[teacherIndex].lessons[lessonIndex]
                                )
                            }
                        }
                    }
                }
            }
            .navigationTitle("💸 Неоплачені Уроки")
        }
    }
}

// MARK: - Lesson Row для цього View
struct UnpaidLessonRow: View {
    let teacherName: String
    @Binding var lesson: Lesson
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(teacherName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(lesson.date, style: .date)
                    .font(.subheadline)
                    
                
                Text(lesson.type.name)
                    .bold()
                + Text(" (\(lesson.durationHours, specifier: "%.1f") год)")
                    .font(.callout)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(lesson.cost, format: .currency(code: "UAH"))
                    .foregroundColor(.red)
                    .font(.title3)
                    .bold()
                
                Button("Оплачено?") {
                    lesson.isPaid.toggle()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
        .padding(.vertical, 4)
    }
}


// MARK: - MonthPicker 

struct MonthPicker: View {
    @Binding var selectedDate: Date
    private let calendar = Calendar.current
    
    var body: some View {
        HStack(spacing: 15) {
            Button {
                changeMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .imageScale(.large)
            }
            
            Text(selectedDate, format: .dateTime.month(.wide).year())
                .font(.headline)
                .frame(minWidth: 120)
            
            Button {
                changeMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .imageScale(.large)
            }
        }
    }
    
    func changeMonth(by amount: Int) {
        if let newDate = calendar.date(byAdding: .month, value: amount, to: selectedDate) {
            selectedDate = newDate
        }
    }
}
