//
//  EditPaymentView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 14.11.2025.
//

import SwiftUI

struct EditPaymentView: View {
    let payment: Payment
    let onSave: (Payment) -> Void
    let onDelete: () -> Void

    @Environment(\.dismiss) var dismiss

    @State private var paymentDate: Date
    @State private var amount: Double?
    @State private var selectedPaymentType: PaymentType
    @State private var note: String
    @State private var showingDeleteConfirmation = false

    init(payment: Payment, onSave: @escaping (Payment) -> Void, onDelete: @escaping () -> Void) {
        self.payment = payment
        self.onSave = onSave
        self.onDelete = onDelete
        self._paymentDate = State(initialValue: payment.date)
        self._amount = State(initialValue: payment.amount)
        self._selectedPaymentType = State(initialValue: payment.type)
        self._note = State(initialValue: payment.note)
    }

    func saveChanges() {
        guard let amount, amount > 0 else { return }
        var updated = payment
        updated.date = paymentDate
        updated.amount = amount
        updated.type = selectedPaymentType
        updated.note = note
        onSave(updated)
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

                PaymentDetailsSection(
                    paymentDate: $paymentDate,
                    selectedPaymentType: $selectedPaymentType,
                    note: $note
                )

                Section {
                    Button("Видалити платіж", role: .destructive) {
                        showingDeleteConfirmation = true
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .appFormStyle()
            .navigationTitle("Редагувати платіж")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Скасувати") { dismiss() }
                }
            }
            .primaryAction("Зберегти зміни", isDisabled: (amount ?? 0) <= 0) {
                saveChanges()
            }
            .confirmationDialog("Видалити цей платіж?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
                Button("Видалити", role: .destructive) {
                    dismiss()
                    onDelete()
                }
            }
        }
    }
}
