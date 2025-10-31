//
//  EditLessonView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 31.10.2025.
//
//
//  EditLessonView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 30.10.2025.
//

import SwiftUI

struct EditLessonView: View {
    @Binding var lesson: Lesson
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataStore: DataStore
    
    @State private var lessonDate: Date
    @State private var durationHours: Double
    @State private var isPaid: Bool
    @State private var selectedType: LessonType?
    @State private var rateApplied: Double
    

    init(lesson: Binding<Lesson>) {
        _lesson = lesson
        
        _lessonDate = State(initialValue: lesson.wrappedValue.date)
        _durationHours = State(initialValue: lesson.wrappedValue.durationHours)
        _isPaid = State(initialValue: lesson.wrappedValue.isPaid)
        _selectedType = State(initialValue: lesson.wrappedValue.type)
        _rateApplied = State(initialValue: lesson.wrappedValue.rateApplied)
    }
    
    let durationFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Деталі Уроку") {
                    DatePicker("Дата Уроку", selection: $lessonDate, displayedComponents: .date)
                    
                    Picker("Тип Уроку", selection: $selectedType) {
                        Text("Оберіть тип").tag(nil as LessonType?)
                        
                        ForEach(dataStore.lessonTypes, id: \.self) { type in
                            Text(type.name)
                                .tag(type as LessonType?)
                        }
                    }

                    HStack {
                        Text("Тривалість (годин)")
                        Spacer()
                        TextField("Години", value: $durationHours, formatter: durationFormatter)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Ставка за годину (грн)")
                        Spacer()
                        TextField("Ставка", value: $rateApplied, format: .currency(code: "UAH"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    .foregroundColor(selectedType != nil ? .primary : .red)
                }
                
                Section("Статус Оплати") {
                    Toggle("Урок оплачено?", isOn: $isPaid)
                }
                
                let cost = durationHours * rateApplied
                Section("Вартість Уроку (Розрахунок)") {
                    HStack {
                        Text("Загальна вартість:")
                        Spacer()
                        Text(cost, format: .currency(code: "UAH"))
                            .bold()
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .navigationTitle("Редагування Уроку")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Скасувати") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Оновити") { updateLesson() }
                        .disabled(selectedType == nil || rateApplied <= 0 || durationHours <= 0)
                }
            }
        }
        
        .onChange(of: selectedType) { newType in
            if let type = newType {
                rateApplied = type.defaultRate
            } else {
                rateApplied = 0.0
            }
        }
    }
    
    func updateLesson() {
        guard let type = selectedType else {
            return
        }
        
        // Оновлюємо оригінальний об'єкт lesson через Binding
        lesson.date = lessonDate
        lesson.durationHours = durationHours
        lesson.isPaid = isPaid
        lesson.type = type
        lesson.rateApplied = rateApplied
        

        
        dismiss()
    }
}
