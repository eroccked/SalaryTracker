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
                                Image(systemName: "pencil.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.accentGreen)
                                Text("Редагування Платежу")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.textPrimary)
                            }
                            Text("Внесіть зміни до платежу")
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
                        Button(action: saveChanges) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Зберегти Зміни")
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
