//
//  LessonTypeManagerView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 31.10.2025.
//

import SwiftUI


struct LessonTypeManagerView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dataStore.lessonTypes.sorted(by: { $0.name < $1.name })) { lessonType in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(lessonType.name)
                                .font(.headline)
                            Text("Базова ставка:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(lessonType.defaultRate, format: .currency(code: "UAH"))
                            .font(.title3)
                            .bold()
                            .foregroundColor(.accentColor)
                    }
                }
                .onDelete(perform: deleteTypes)
            }
            .navigationTitle("Керування Типами Уроків")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Label("Додати тип", systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddLessonTypeView()
                    .environmentObject(dataStore)
            }
        }
    }
    
    func deleteTypes(offsets: IndexSet) {
        dataStore.lessonTypes.remove(atOffsets: offsets)
    }
}



struct AddLessonTypeView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss
    
    @State private var typeName: String = ""
    @State private var defaultRate: Double = 450
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Назва типу (напр. 'Індивідуальний')", text: $typeName)
                
                HStack {
                    Text("Базова ставка (грн)")
                    Spacer()
                    TextField("Ставка", value: $defaultRate, format: .currency(code: "UAH"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
            }
            .navigationTitle("Новий Тип Уроку")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Скасувати") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Зберегти") { saveNewType() }
                        .disabled(typeName.isEmpty || defaultRate <= 0)
                }
            }
        }
    }
    
    func saveNewType() {
        let newType = LessonType(name: typeName, defaultRate: defaultRate)
        dataStore.lessonTypes.append(newType)
        dismiss()
    }
}
