//
//  AddLessonView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 30.10.2025.
//

import SwiftUI

struct AddLessonView: View {

    @Binding var teacherLessons: [Lesson]
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss

    @State private var lessonDate = Date()
    @State private var durationHours: Int = 1
    @State private var rateApplied: Double = 450
    
    @State private var selectedLessonType: LessonType? = nil
    
    let availableHours = Array(1...10)
    
    func saveLesson() {
        guard let finalLessonType = selectedLessonType else {
            print("Помилка: Не обрано тип уроку.")
            return
        }

        let newLesson = Lesson(
            date: lessonDate,
            durationHours: Double(durationHours),
            type: finalLessonType,
            rateApplied: rateApplied
        )
        
        teacherLessons.append(newLesson)
        dataStore.saveTeachers()
        dismiss()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Деталі уроку") {
                    DatePicker("Дата Уроку", selection: $lessonDate, displayedComponents: .date)
                    
                    Picker("Тривалість (годин)", selection: $durationHours) {
                        ForEach(availableHours, id: \.self) { hour in
                            Text("\(hour) год")
                        }
                    }
                    
                    Picker("Тип Уроку", selection: $selectedLessonType) {
                        Text("Оберіть тип").tag(nil as LessonType?)
                        ForEach(dataStore.lessonTypes, id: \.self) { type in
                            Text(type.name).tag(type as LessonType?)
                        }
                    }
                    
                    HStack {
                        Text("Ставка за годину (грн)")
                        Spacer()
                        TextField("Ставка", value: $rateApplied, format: .currency(code: "UAH"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section {
                    Button("Зберегти Урок") {
                        saveLesson()
                    }
                    .disabled(selectedLessonType == nil)
                }
            }
            .navigationTitle("Додати Урок")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Відмінити") {
                        dismiss()
                    }
                }
            }
            .onChange(of: selectedLessonType) { _, newType in
                if let type = newType {
                    rateApplied = type.defaultRate
                }
            }
            .onAppear {
                if selectedLessonType == nil {
                    selectedLessonType = dataStore.lessonTypes.first
                }
            }
        }
    }
}
