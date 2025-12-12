//
//  EditLessonView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 06.11.2025.
//
import SwiftUI

struct EditLessonView: View {
    @Binding var lesson: Lesson
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss
    
    @State private var lessonDate: Date
    @State private var durationHours: Int
    @State private var rateApplied: Double
    @State private var selectedLessonType: LessonType
    
    let availableHours = Array(1...10)
    
    init(lesson: Binding<Lesson>) {
        self._lesson = lesson
        
        self._lessonDate = State(initialValue: lesson.wrappedValue.date)
        
        self._durationHours = State(initialValue: Int(lesson.wrappedValue.durationHours.rounded()))
        
        self._rateApplied = State(initialValue: lesson.wrappedValue.rateApplied)
        self._selectedLessonType = State(initialValue: lesson.wrappedValue.type)
    }
    
    func saveChanges() {
        lesson.date = lessonDate
        lesson.durationHours = Double(durationHours)
        lesson.rateApplied = rateApplied
        lesson.type = selectedLessonType
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
                                Text("Редагування Уроку")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.textPrimary)
                            }
                            Text("Внесіть зміни до уроку")
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
                            // Date and Type - Horizontal at the top
                            HStack(spacing: 12) {
                                // Date Picker
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("Дата Уроку", systemImage: "calendar")
                                        .font(.subheadline)
                                        .foregroundColor(.textSecondary)
                                    
                                    DatePicker("", selection: $lessonDate, displayedComponents: .date)
                                        .labelsHidden()
                                        .datePickerStyle(.compact)
                                        .tint(.accentGreen)
                                }
                                .padding()
                                .background(Color.cardBackground)
                                .cornerRadius(12)
                                .frame(maxWidth: .infinity)
                                
                                // Lesson Type Picker
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("Тип Уроку", systemImage: "tag.fill")
                                        .font(.subheadline)
                                        .foregroundColor(.textSecondary)
                                    
                                    Picker("", selection: $selectedLessonType) {
                                        ForEach(dataStore.lessonTypes, id: \.self) { type in
                                            Text(type.name).tag(type)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .tint(.accentGreen)
                                }
                                .padding()
                                .background(Color.cardBackground)
                                .cornerRadius(12)
                                .frame(maxWidth: .infinity)
                            }
                            
                            // Duration Picker
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Тривалість (годин)", systemImage: "clock.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.textSecondary)
                                
                                Picker("", selection: $durationHours) {
                                    ForEach(availableHours, id: \.self) { hour in
                                        Text("\(hour) год").tag(hour)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(height: 120)
                            }
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(12)
                            
                            // Rate Field
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Ставка за годину (грн)", systemImage: "banknote.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.textSecondary)
                                
                                HStack {
                                    TextField("Ставка", value: $rateApplied, format: .currency(code: "UAH"))
                                        .keyboardType(.decimalPad)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.textPrimary)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                    
                                    Text("UAH")
                                        .foregroundColor(.textSecondary)
                                }
                            }
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(12)
                            
                            // Total Cost Preview
                            VStack(spacing: 8) {
                                Text("Вартість уроку")
                                    .font(.subheadline)
                                    .foregroundColor(.textSecondary)
                                
                                Text(Double(durationHours) * rateApplied, format: .currency(code: "UAH"))
                                    .font(.title)
                                    .fontWeight(.heavy)
                                    .foregroundColor(.accentGreen)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.accentGreen.opacity(0.1), Color.accentGreen.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
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
                            .background(Color.accentGreen)
                            .cornerRadius(15)
                            .shadow(color: Color.accentGreen.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
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
            .onChange(of: selectedLessonType) { _, newType in
                if newType.defaultRate != lesson.type.defaultRate {
                    rateApplied = newType.defaultRate
                }
            }
        }
    }
}
