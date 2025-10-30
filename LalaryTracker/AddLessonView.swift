//
//  AddLessonView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 30.10.2025.
//

import SwiftUI

struct AddLessonView: View {
    @Binding var teacherLessons: [Lesson]
    @Environment(\.dismiss) var dismiss
    
    @State private var lessonDate = Date()
    @State private var durationHours: Double = 1.0 // Початкове значення
    @State private var rateApplied: Double = 300.0 // Початкове значення ставки
    @State private var lessonType: String = ""
    @State private var isPaid: Bool = false
    
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
                    
                    TextField("Тип уроку (напр. 'Груповий')", text: $lessonType)
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
            .navigationTitle("Додати Урок")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Скасувати") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Зберегти") { saveLesson() }
                        .disabled(rateApplied <= 0 || durationHours <= 0)
                }
            }
        }
    }
    
    func saveLesson() {

        let newLesson = Lesson(
                date: lessonDate,
                durationHours: durationHours,
                rateApplied: rateApplied,
                type: lessonType.isEmpty ? nil : lessonType,
                isPaid: isPaid
            )
        
        // Додаємо його до масиву уроків викладача
        teacherLessons.append(newLesson)
        
        // Закриваємо модальне вікно
        dismiss()
    }
}
