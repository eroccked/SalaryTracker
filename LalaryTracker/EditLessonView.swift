//
//  EditLessonView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 06.11.2025.
//

import SwiftUI

struct EditLessonView: View {
    let lesson: Lesson
    let onSave: (Lesson) -> Void
    let onDelete: () -> Void

    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss

    @State private var lessonDate: Date
    @State private var durationHours: Int
    @State private var rateApplied: Double
    @State private var selectedLessonType: LessonType
    @State private var showingDeleteConfirmation = false

    let availableHours = Array(1...10)

    init(lesson: Lesson, onSave: @escaping (Lesson) -> Void, onDelete: @escaping () -> Void) {
        self.lesson = lesson
        self.onSave = onSave
        self.onDelete = onDelete
        self._lessonDate = State(initialValue: lesson.date)
        self._durationHours = State(initialValue: Int(lesson.durationHours.rounded()))
        self._rateApplied = State(initialValue: lesson.rateApplied)
        self._selectedLessonType = State(initialValue: lesson.type)
    }

    /// Поточний тип теж має бути у списку, навіть якщо його вже видалили з налаштувань
    var lessonTypeOptions: [LessonType] {
        dataStore.lessonTypes.contains(lesson.type) ? dataStore.lessonTypes : [lesson.type] + dataStore.lessonTypes
    }

    func saveChanges() {
        var updated = lesson
        updated.date = lessonDate
        updated.durationHours = Double(durationHours)
        updated.rateApplied = rateApplied
        updated.type = selectedLessonType
        onSave(updated)
        dismiss()
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    FormAmountHeader(
                        caption: "Вартість уроку",
                        amount: Double(durationHours) * rateApplied,
                        detail: "\(Fmt.hours(Double(durationHours))) × \(Fmt.money(rateApplied))"
                    )
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)

                Section("Деталі уроку") {
                    DatePicker("Дата", selection: $lessonDate, displayedComponents: .date)

                    Picker("Тривалість", selection: $durationHours) {
                        ForEach(availableHours, id: \.self) { hour in
                            Text("\(hour) год")
                        }
                    }

                    Picker("Тип уроку", selection: $selectedLessonType) {
                        ForEach(lessonTypeOptions, id: \.self) { type in
                            Text(type.name).tag(type)
                        }
                    }

                    RateField(rate: $rateApplied)
                }

                Section {
                    Button("Видалити урок", role: .destructive) {
                        showingDeleteConfirmation = true
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .appFormStyle()
            .navigationTitle("Редагувати урок")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Скасувати") { dismiss() }
                }
            }
            .primaryAction("Зберегти зміни") {
                saveChanges()
            }
            .confirmationDialog("Видалити цей урок?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
                Button("Видалити", role: .destructive) {
                    dismiss()
                    onDelete()
                }
            }
            .onChange(of: selectedLessonType) { _, newType in
                if newType.defaultRate != lesson.type.defaultRate {
                    rateApplied = newType.defaultRate
                }
            }
        }
    }
}
