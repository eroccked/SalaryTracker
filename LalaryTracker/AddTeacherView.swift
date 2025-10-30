//
//  AddTeacherView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 30.10.2025.
//

import SwiftUI

struct AddTeacherView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss
    
    @State private var teacherName: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Ім'я та Прізвище", text: $teacherName)
            }
            .navigationTitle("Новий Викладач")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Скасувати") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Зберегти") {
                        saveTeacher()
                    }
                    // Кнопка активна лише якщо ім'я не пусте
                    .disabled(teacherName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    func saveTeacher() {
        let newTeacher = Teacher(name: teacherName)
        
        dataStore.teachers.append(newTeacher)
        
        dismiss()
    }
}
