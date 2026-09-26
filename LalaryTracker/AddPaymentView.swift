//
//  AddPaymentView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 14.11.2025.
//

import SwiftUI

struct AddPaymentView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss

    // MARK: - State Properties
    @State private var selectedTeacherID: UUID?
    @State private var paymentDate = Date()
    @State private var amount: Double?
    @State private var selectedPaymentType: PaymentType = .cash
    @State private var note: String = ""

    /// teacherID — якщо відкрито зі сторінки викладача, він уже обраний
    init(teacherID: UUID? = nil) {
        _selectedTeacherID = State(initialValue: teacherID)
    }

    // MARK: - Функція збереження
    func savePayment() {
        guard
            let amount, amount > 0,
            let teacherIndex = dataStore.teachers.firstIndex(where: { $0.id == selectedTeacherID })
        else { return }

        let newPayment = Payment(
            date: paymentDate,
            amount: amount,
            type: selectedPaymentType,
            note: note
        )

        dataStore.teachers[teacherIndex].payments.append(newPayment)
        dismiss()
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    AmountInputHeader(amount: $amount)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)

                TeacherPickerSection(selectedTeacherID: $selectedTeacherID)

                PaymentDetailsSection(
                    paymentDate: $paymentDate,
                    selectedPaymentType: $selectedPaymentType,
                    note: $note
                )
            }
            .appFormStyle()
            .navigationTitle("Новий платіж")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Скасувати") { dismiss() }
                }
            }
            .primaryAction("Зберегти платіж", isDisabled: (amount ?? 0) <= 0 || selectedTeacherID == nil) {
                savePayment()
            }
            .onAppear {
                if selectedTeacherID == nil {
                    selectedTeacherID = dataStore.teachers.first?.id
                }
            }
        }
    }
}

// MARK: - Спільні елементи форм платежу

/// Велике поле суми на градієнті
struct AmountInputHeader: View {
    @Binding var amount: Double?
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 6) {
            Text("Сума платежу")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                TextField("", value: $amount, format: .number, prompt: Text("0").foregroundStyle(.white.opacity(0.5)))
                    .keyboardType(.decimalPad)
                    .focused($isFocused)
                    .multilineTextAlignment(.center)
                    .fixedSize()
                Text("₴")
            }
            .font(.system(size: 38, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .tint(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 26)
        .background(AppBackground().clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous)))
        .contentShape(Rectangle())
        .onTapGesture { isFocused = true }
    }
}

struct PaymentDetailsSection: View {
    @Binding var paymentDate: Date
    @Binding var selectedPaymentType: PaymentType
    @Binding var note: String

    var body: some View {
        Section("Деталі платежу") {
            DatePicker("Дата", selection: $paymentDate, displayedComponents: .date)

            Picker("Спосіб", selection: $selectedPaymentType) {
                ForEach(PaymentType.allCases) { type in
                    Label(type.rawValue, systemImage: type.icon)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
            .listRowBackground(Color.surface)

            TextField("Примітка (необов'язково)", text: $note, axis: .vertical)
                .lineLimit(2...4)
        }
    }
}
