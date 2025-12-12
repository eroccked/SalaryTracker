//
//  AddTeacherView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 30.10.2025.
//  Updated with new design
//

import SwiftUI

struct AddTeacherView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss
    
    @State private var teacherName: String = ""
    
    var body: some View {
        NavigationView {
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
                
                VStack(spacing: 20) {
                    
                    // Header Card
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "person.fill.badge.plus")
                                .font(.title2)
                                .foregroundColor(.accentGreen)
                            Text("Новий Викладач")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.textPrimary)
                        }
                        Text("Додайте нового викладача до списку")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(15)
                    .padding(.horizontal)
                    .padding(.top, 30)
                    
                    // Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Ім'я та Прізвище", systemImage: "person.fill")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                        
                        TextField("Введіть ім'я викладача", text: $teacherName)
                            .textFieldStyle(.plain)
                            .font(.title3)
                            .foregroundColor(.textPrimary)
                            .padding()
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(10)
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Save Button
                    Button(action: saveTeacher) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Зберегти")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(teacherName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.accentGreen)
                        .cornerRadius(15)
                        .shadow(color: Color.accentGreen.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .disabled(teacherName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .tint(.textPrimary)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Скасувати") {
                        dismiss()
                    }
                    .foregroundColor(.textSecondary)
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
