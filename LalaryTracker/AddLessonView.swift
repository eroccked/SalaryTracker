//
//  AddLessonView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 30.10.2025.
//

import SwiftUI

struct AddLessonView: View {

    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedTeacherID: UUID?
    @State private var lessonDate = Date()
    @State private var durationHours: Int = 1
    @State private var rateApplied: Double = 450
    @State private var selectedLessonType: LessonType? = nil

    let availableHours = Array(1...10)

    /// teacherID — якщо відкрито зі сторінки викладача, він уже обраний
    init(teacherID: UUID? = nil) {
        _selectedTeacherID = State(initialValue: teacherID)
    }

    func saveLesson() {
        guard
            let finalLessonType = selectedLessonType,
            let teacherIndex = dataStore.teachers.firstIndex(where: { $0.id == selectedTeacherID })
        else { return }

        let newLesson = Lesson(
            date: lessonDate,
            durationHours: Double(durationHours),
            type: finalLessonType,
            rateApplied: rateApplied
        )

        dataStore.teachers[teacherIndex].lessons.append(newLesson)
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

                TeacherPickerSection(selectedTeacherID: $selectedTeacherID)

                Section("Деталі уроку") {
                    DatePicker("Дата", selection: $lessonDate, displayedComponents: .date)

                    Picker("Тривалість", selection: $durationHours) {
                        ForEach(availableHours, id: \.self) { hour in
                            Text("\(hour) год")
                        }
                    }

                    Picker("Тип уроку", selection: $selectedLessonType) {
                        Text("Оберіть тип").tag(nil as LessonType?)
                        ForEach(dataStore.lessonTypes, id: \.self) { type in
                            Text(type.name).tag(type as LessonType?)
                        }
                    }

                    RateField(rate: $rateApplied)
                }
            }
            .appFormStyle()
            .navigationTitle("Новий урок")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Скасувати") { dismiss() }
                }
            }
            .primaryAction("Зберегти урок", isDisabled: selectedLessonType == nil || selectedTeacherID == nil) {
                saveLesson()
            }
            .onChange(of: selectedLessonType) { _, newType in
                if let type = newType {
                    rateApplied = type.defaultRate
                }
            }
            .onAppear {
                if selectedTeacherID == nil {
                    selectedTeacherID = dataStore.teachers.first?.id
                }
                if selectedLessonType == nil {
                    selectedLessonType = dataStore.lessonTypes.first
                }
            }
        }
    }
}

// MARK: - Спільні елементи форм

/// Градієнтна картка з сумою зверху форми
struct FormAmountHeader: View {
    let caption: String
    let amount: Double
    var detail: String? = nil

    var body: some View {
        VStack(spacing: 6) {
            Text(caption)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
            Text(Fmt.money(amount))
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .contentTransition(.numericText())
                .animation(.snappy, value: amount)
            if let detail {
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(AppBackground().clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous)))
    }
}

/// Вибір викладача (для додавання через «+»)
struct TeacherPickerSection: View {
    @EnvironmentObject var dataStore: DataStore
    @Binding var selectedTeacherID: UUID?

    var body: some View {
        Section("Викладач") {
            if dataStore.teachers.isEmpty {
                Text("Спочатку додайте викладача")
                    .foregroundStyle(Color.inkSecondary)
            } else {
                Picker(selection: $selectedTeacherID) {
                    ForEach(dataStore.teachers) { teacher in
                        Text(teacher.name).tag(teacher.id as UUID?)
                    }
                } label: {
                    HStack(spacing: 12) {
                        if let teacher = dataStore.teachers.first(where: { $0.id == selectedTeacherID }) {
                            AvatarView(name: teacher.name, size: 32)
                        }
                        Text("Викладач")
                    }
                }
            }
        }
    }
}

/// Поле ставки за годину
struct RateField: View {
    @Binding var rate: Double

    var body: some View {
        HStack {
            Text("Ставка, ₴/год")
            Spacer()
            TextField("Ставка", value: $rate, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .fontWeight(.semibold)
        }
    }
}
