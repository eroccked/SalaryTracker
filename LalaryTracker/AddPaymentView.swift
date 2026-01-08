//
//  AddPaymentView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 14.11.2025.
//  Updated with new design
//

import SwiftUI

struct AddPaymentView: View {
    @Binding var teacher: Teacher
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss

    // MARK: - State Properties
    @State private var paymentDate = Date()
    @State private var amount: Double = 0.0
    @State private var selectedPaymentType: PaymentType = .cash
    @State private var note: String = ""

    // MARK: - Функція збереження
    func savePayment() {
        guard amount > 0 else {
            print("Помилка: Сума платежу має бути більшою за нуль.")
            return
        }

        let newPayment = Payment(
            date: paymentDate,
            amount: amount,
            type: selectedPaymentType,
            note: note
        )
        
        teacher.payments.append(newPayment)
        dataStore.saveTeachers()
        dismiss()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Деталі Платежу") {
                    DatePicker("Дата Платежу", selection: $paymentDate, displayedComponents: .date)
                    
                    HStack {
                        Text("Сума (UAH)")
                        Spacer()
                        TextField("0.00", value: $amount, format: .currency(code: "UAH"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Тип Платежу", selection: $selectedPaymentType) {
                        ForEach(PaymentType.allCases) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    
                    TextField("Примітка (необов'язково)", text: $note, axis: .vertical)
                        .lineLimit(3...5)
                }
                
                Section {
                    Button("Зберегти Платіж") {
                        savePayment()
                    }
                    .disabled(amount <= 0)
                }
            }
            .navigationTitle("Додати Платіж")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Відмінити") {
                        dismiss()
                    }
                }
            }
        }
    }
}
