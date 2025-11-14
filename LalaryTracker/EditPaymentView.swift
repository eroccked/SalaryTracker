//
//  EditPaymentView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 14.11.2025.
//

import SwiftUI

struct EditPaymentView: View {
    @Binding var payment: Payment
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss
    
    @State private var paymentDate: Date
    @State private var amount: Double
    @State private var selectedPaymentType: PaymentType
    @State private var note: String
    
    init(payment: Binding<Payment>) {
        self._payment = payment
        self._paymentDate = State(initialValue: payment.wrappedValue.date)
        self._amount = State(initialValue: payment.wrappedValue.amount)
        self._selectedPaymentType = State(initialValue: payment.wrappedValue.type)
        self._note = State(initialValue: payment.wrappedValue.note)
    }
    
    func saveChanges() {
        payment.date = paymentDate
        payment.amount = amount
        payment.type = selectedPaymentType
        payment.note = note
        
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
                    
                    TextField("Примітка (необов'язково)", text: $note)
                }
                
                Section {
                    Button("Зберегти Зміни") {
                        saveChanges()
                    }
                    .disabled(amount <= 0)
                }
            }
            .navigationTitle("Редагувати Платіж")
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
