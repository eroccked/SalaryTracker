//
//  LessonTypeManagerView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 31.10.2025.
//  Updated with new design
//

import SwiftUI


struct LessonTypeManagerView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var showingAddSheet = false
    
    func deleteTypes(offsets: IndexSet) {
        dataStore.lessonTypes.remove(atOffsets: offsets)
    }
    
    var body: some View {
        NavigationView {
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
                    VStack(spacing: 15) {
                        if dataStore.lessonTypes.isEmpty {
                            VStack(spacing: 20) {
                                Spacer()
                                    .frame(height: 100)
                                
                                Image(systemName: "tag.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.textSecondary)
                                
                                Text("Немає типів уроків")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.textPrimary)
                                
                                Text("Додайте типи для класифікації уроків")
                                    .font(.subheadline)
                                    .foregroundColor(.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                        } else {
                            ForEach(dataStore.lessonTypes.sorted(by: { $0.name < $1.name })) { lessonType in
                                HStack(spacing: 15) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.accentGreen.opacity(0.15))
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: "tag.fill")
                                            .foregroundColor(.accentGreen)
                                            .font(.title3)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(lessonType.name)
                                            .font(.headline)
                                            .foregroundColor(.textPrimary)
                                        Text("Базова ставка")
                                            .font(.caption)
                                            .foregroundColor(.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(lessonType.defaultRate, format: .currency(code: "UAH"))
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(.accentGreen)
                                }
                                .padding()
                                .background(Color.cardBackground)
                                .cornerRadius(15)
                                .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                                .padding(.horizontal)
                            }
                            .onDelete(perform: deleteTypes)
                        }
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Типи Уроків")
            .tint(.textPrimary)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !dataStore.lessonTypes.isEmpty {
                        EditButton()
                            .foregroundColor(.textPrimary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.accentGreen)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddLessonTypeView()
                    .environmentObject(dataStore)
            }
        }
    }
}



struct AddLessonTypeView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss
    
    @State private var typeName: String = ""
    @State private var defaultRate: Double = 450
    
    var body: some View {
        NavigationView {
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
                
                VStack(spacing: 20) {
                    
                    // Header Card
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "tag.fill")
                                .font(.title2)
                                .foregroundColor(.accentGreen)
                            Text("Новий Тип Уроку")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.textPrimary)
                        }
                        Text("Створіть новий тип для класифікації")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(15)
                    .padding(.horizontal)
                    .padding(.top, 30)
                    
                    // Form Fields
                    VStack(spacing: 15) {
                        // Type Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Назва типу", systemImage: "textformat")
                                .font(.subheadline)
                                .foregroundColor(.textSecondary)
                            
                            TextField("Наприклад: 'Індивідуальний'", text: $typeName)
                                .textFieldStyle(.plain)
                                .font(.title3)
                                .foregroundColor(.textPrimary)
                                .padding()
                                .background(Color.white.opacity(0.5))
                                .cornerRadius(10)
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                        
                        // Rate Field
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Базова ставка (грн)", systemImage: "banknote.fill")
                                .font(.subheadline)
                                .foregroundColor(.textSecondary)
                            
                            HStack {
                                TextField("Ставка", value: $defaultRate, format: .currency(code: "UAH"))
                                    .keyboardType(.decimalPad)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.textPrimary)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                Text("UAH")
                                    .foregroundColor(.textSecondary)
                            }
                            .padding()
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(10)
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Save Button
                    Button(action: saveNewType) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Зберегти")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background((typeName.isEmpty || defaultRate <= 0) ? Color.gray : Color.accentGreen)
                        .cornerRadius(15)
                        .shadow(color: Color.accentGreen.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .disabled(typeName.isEmpty || defaultRate <= 0)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .tint(.textPrimary)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Скасувати") {
                        dismiss()
                    }
                    .foregroundColor(.textSecondary)
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
