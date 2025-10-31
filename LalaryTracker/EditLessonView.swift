import SwiftUI

struct EditLessonView: View {
    @Binding var lesson: Lesson
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss
    
    @State private var lessonDate: Date
    @State private var durationHours: Int
    @State private var rateApplied: Double
    @State private var selectedLessonType: LessonType
    @State private var isPaid: Bool
    
    let availableHours = Array(1...10)
    
    init(lesson: Binding<Lesson>) {
        self._lesson = lesson
        
        self._lessonDate = State(initialValue: lesson.wrappedValue.date)
        
        self._durationHours = State(initialValue: Int(lesson.wrappedValue.durationHours.rounded()))
        
        self._rateApplied = State(initialValue: lesson.wrappedValue.rateApplied)
        self._selectedLessonType = State(initialValue: lesson.wrappedValue.type)
        self._isPaid = State(initialValue: lesson.wrappedValue.isPaid)
    }
    
    func saveChanges() {
        lesson.date = lessonDate
        lesson.durationHours = Double(durationHours) //
        lesson.rateApplied = rateApplied
        lesson.type = selectedLessonType
        lesson.isPaid = isPaid
        
        dismiss()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Деталі уроку") {
                    DatePicker("Дата Уроку", selection: $lessonDate, displayedComponents: .date)
                    
                    Picker("Тривалість (годин)", selection: $durationHours) {
                        ForEach(availableHours, id: \.self) { hour in
                            Text("\(hour) год")
                        }
                    }
                    .pickerStyle(.wheel)

                    Picker("Тип Уроку", selection: $selectedLessonType) {

                        ForEach(dataStore.lessonTypes) { type in
                            Text(type.name).tag(type)
                        }
                    }
                    HStack {
                        Text("Ставка за годину (грн)")
                        Spacer()
                        TextField("Ставка", value: $rateApplied, format: .currency(code: "UAH"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Вартість уроку")
                        Spacer()
                        Text(Double(durationHours) * rateApplied, format: .currency(code: "UAH"))
                            .fontWeight(.bold)
                    }
                }
                
                Section("Статус Оплати") {
                    Toggle("Урок оплачено?", isOn: $isPaid)
                }
                
                Section {
                    Button("Зберегти Зміни") {
                        saveChanges()
                    }
                }
            }
            .navigationTitle("Редагувати Урок")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Відмінити") {
                        dismiss()
                    }
                }
            }
            .onChange(of: selectedLessonType) { newType in
                if rateApplied != lesson.rateApplied {
                    rateApplied = newType.defaultRate
                }
            }
        }
    }
}
