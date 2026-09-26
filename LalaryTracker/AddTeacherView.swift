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
    @FocusState private var isNameFocused: Bool

    private var trimmedName: String {
        teacherName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(spacing: 12) {
                        AvatarView(name: trimmedName.isEmpty ? "?" : trimmedName, size: 84)
                            .overlay(Circle().stroke(.white.opacity(0.7), lineWidth: 3))
                            .animation(.snappy, value: trimmedName)
                        Text(trimmedName.isEmpty ? "Новий викладач" : trimmedName)
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 26)
                    .background(AppBackground().clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous)))
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)

                Section("Профіль") {
                    TextField("Ім'я та прізвище", text: $teacherName)
                        .focused($isNameFocused)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.done)
                        .onSubmit { if !trimmedName.isEmpty { saveTeacher() } }
                }
            }
            .appFormStyle()
            .navigationTitle("Новий викладач")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Скасувати") { dismiss() }
                }
            }
            .primaryAction("Додати викладача", isDisabled: trimmedName.isEmpty) {
                saveTeacher()
            }
            .onAppear { isNameFocused = true }
        }
    }

    func saveTeacher() {
        let newTeacher = Teacher(name: trimmedName)
        dataStore.teachers.append(newTeacher)
        dismiss()
    }
}
