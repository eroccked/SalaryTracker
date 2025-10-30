//
//  TeacherListView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 30.10.2025.
//

import SwiftUI

struct TeachersListView: View {
    
    @EnvironmentObject var dataStore: DataStore
    
    @State private var showingAddTeacherSheet = false
    
    var body: some View {
        NavigationView {
            
            List {
                if dataStore.teachers.isEmpty {
                    ContentUnavailableView("Немає викладачів",
                                           systemImage: "person.3.fill",
                                           description: Text("Натисніть '+' для додавання нового профілю."))
                }
                
                ForEach($dataStore.teachers) { $teacher in
                    
                    NavigationLink {
                        // Тут буде наступний екран: LessonsView (ми його створимо пізніше)
                        TeacherDetailsView(teacher: $teacher)
                    } label: {
                        TeacherRow(teacher: teacher)
                    }
                }
                .onDelete(perform: deleteTeacher)
            }
            .navigationTitle("🧑‍🏫 Викладачі")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton() // Стандартна кнопка редагування для List
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Кнопка для додавання нового викладача
                    Button {
                        showingAddTeacherSheet = true
                    } label: {
                        Label("Додати викладача", systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddTeacherSheet) {
                AddTeacherView()
                    .environmentObject(dataStore)
            }
        }
    }
    
    func deleteTeacher(offsets: IndexSet) {
        dataStore.teachers.remove(atOffsets: offsets)
    }
}


struct TeacherRow: View {
    let teacher: Teacher
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(teacher.name)
                    .font(.headline)
                Text("Уроків: \(teacher.lessons.count)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("До виплати:")
                    .font(.caption)
                Text(teacher.totalUnpaidSalary, format: .currency(code: "UAH"))
                    .foregroundColor(teacher.totalUnpaidSalary > 0 ? .red : .primary)
                    .bold()
            }
        }
    }
}
