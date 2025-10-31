//
//  TeacherListView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 30.10.2025.
//

import SwiftUI

struct TeachersListView: View {
    
    @EnvironmentObject var dataStore: DataStore
    
    @State private var showingTypeManagerSheet = false
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
                        TeacherDetailsView(teacher: $teacher)
                            .environmentObject(dataStore)
                    } label: {
                        TeacherRow(teacher: teacher)
                    }
                }
                .onDelete(perform: deleteTeacher)
            }
            .navigationTitle("🧑‍🏫 Викладачі")
            .toolbar {
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingTypeManagerSheet = true
                    } label: {
                        Label("Керування Типами", systemImage: "gearshape.fill")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }

                ToolbarItem(placement: .navigationBarTrailing) {
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

            .sheet(isPresented: $showingTypeManagerSheet) {
                LessonTypeManagerView()
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
        HStack(alignment: .center) {
            
  
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.accentColor)
            
            VStack(alignment: .leading, spacing: 4) {
                // 2. Ім'я
                Text(teacher.name)
                    .font(.headline)
                    .lineLimit(1)
                
               
                Text("Уроків: \(teacher.lessons.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()

            VStack(alignment: .trailing) {
                Text("ДО СПЛАТИ")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                
      
                Text(teacher.totalUnpaidSalary, format: .currency(code: "UAH"))
                    .font(.title3)
                    .fontWeight(.bold)
                    // Колір залежить від наявності боргу
                    .foregroundColor(teacher.totalUnpaidSalary > 0 ? .red : .green)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(teacher.totalUnpaidSalary > 0 ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
            )
        }
        .padding(.vertical, 4)
    }
}
