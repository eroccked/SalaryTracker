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
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Header Card
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "banknote.fill")
                                    .font(.title2)
                                    .foregroundColor(.accentGreen)
                                Text("Новий Платіж")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.textPrimary)
                            }
                            Text("Заповніть деталі платежу")
                                .font(.subheadline)
                                .foregroundColor(.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(15)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        // Form Fields
                        VStack(spacing: 15) {
                            // Date Picker
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Дата Платежу", systemImage: "calendar")
                                    .font(.subheadline)
                                    .foregroundColor(.textSecondary)
                                
                                DatePicker("", selection: $paymentDate, displayedComponents: .date)
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
                                    .tint(.accentGreen)
                            }
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(12)
                            
                            // Amount Field
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Сума (UAH)", systemImage: "dollarsign.circle.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.textSecondary)
                                
                                HStack {
                                    TextField("0.00", value: $amount, format: .currency(code: "UAH"))
                                        .keyboardType(.decimalPad)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.accentGreen)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                    
                                    Text("UAH")
                                        .foregroundColor(.textSecondary)
                                }
                            }
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(12)
                            
                            // Payment Type Picker
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Тип Платежу", systemImage: "creditcard.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.textSecondary)
                                
                                HStack(spacing: 12) {
                                    ForEach(PaymentType.allCases) { type in
                                        Button {
                                            selectedPaymentType = type
                                        } label: {
                                            VStack(spacing: 8) {
                                                Image(systemName: type.icon)
                                                    .font(.title2)
                                                    .foregroundColor(selectedPaymentType == type ? .white : .textPrimary)
                                                
                                                Text(type.rawValue)
                                                    .font(.caption)
                                                    .foregroundColor(selectedPaymentType == type ? .white : .textSecondary)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(selectedPaymentType == type ? Color.accentGreen : Color.white.opacity(0.5))
                                            .cornerRadius(12)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(12)
                            
                            // Note Field
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Примітка (необов'язково)", systemImage: "note.text")
                                    .font(.subheadline)
                                    .foregroundColor(.textSecondary)
                                
                                TextField("Додайте примітку...", text: $note, axis: .vertical)
                                    .lineLimit(3...5)
                                    .textFieldStyle(.plain)
                                    .font(.body)
                                    .foregroundColor(.textPrimary)
                            }
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        // Save Button
                        Button(action: savePayment) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Зберегти Платіж")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(amount <= 0 ? Color.gray : Color.accentGreen)
                            .cornerRadius(15)
                            .shadow(color: Color.accentGreen.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                        .disabled(amount <= 0)
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .tint(.textPrimary)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Відмінити") {
                        dismiss()
                    }
                    .foregroundColor(.textSecondary)
                }
            }
        }
    }
}
