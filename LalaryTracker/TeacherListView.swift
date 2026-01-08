//
//  TeacherListView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 30.10.2025.
//

import SwiftUI

struct TeachersListView: View {
    
    @EnvironmentObject var dataStore: DataStore
    
    @State private var showingTypeManagerSheet = false
    @State private var showingAddTeacherSheet = false
    @State private var showingUnpaidLessonsSheet = false
    
    func deleteTeacher(offsets: IndexSet) {
        dataStore.teachers.remove(atOffsets: offsets)
    }
    
    var body: some View {
        NavigationStack {
            
            List {
                if dataStore.teachers.isEmpty {
                    ContentUnavailableView("Немає викладачів",
                                           systemImage: "person.3.fill",
                                           description: Text("Натисніть '+' для додавання нового профілю."))
                }
                
                ForEach($dataStore.teachers) { $teacher in
                    
                    NavigationLink {
                        TeacherDetailsView(teacher: $teacher)
                            .environmentObject(dataStore)
                    } label: {
                        TeacherRow(teacher: teacher)
                    }
                }
                .onDelete(perform: deleteTeacher)
            }
            .navigationTitle("🧑‍🏫 Викладачі")
            .toolbar {
                
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    
                    EditButton()
                    
                    Button {
                        showingTypeManagerSheet = true
                    } label: {
                        Label("Керування Типами", systemImage: "gearshape.fill")
                    }
                    
                    Button {
                        showingUnpaidLessonsSheet = true
                    } label: {
                        Label("Баланс", systemImage: "banknote.fill")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTeacherSheet = true
                    } label: {
                        Label("Додати викладача", systemImage: "plus.circle.fill")
                    }
                }
                
            }
            
            .sheet(isPresented: $showingAddTeacherSheet) {
                AddTeacherView()
                    .environmentObject(dataStore)
            }

            .sheet(isPresented: $showingTypeManagerSheet) {
                LessonTypeManagerView()
                    .environmentObject(dataStore)
            }
            .sheet(isPresented: $showingUnpaidLessonsSheet) {
                UnpaidLessonsView()
                    .environmentObject(dataStore)
            }
        }
    }
}


struct TeacherRow: View {
    let teacher: Teacher
    
    // Баланс за поточний місяць
    var currentMonthBalance: Double {
        let now = Date()
        let earned = teacher.totalEarned(for: now)
        let paid = teacher.totalPayments(for: now)
        return earned - paid
    }
    
    // Поточний місяць
    var currentMonthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        formatter.locale = Locale(identifier: "uk_UA")
        return formatter.string(from: Date()).capitalized
    }
    
    var body: some View {
        let balance = currentMonthBalance
        let isOwed = balance > 0
        
        return HStack(alignment: .center) {
            
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 37, height: 37) // 40 * 0.67 ≈ 27
                .foregroundColor(.accentColor)
            
            VStack(alignment: .leading, spacing: 2) { // 4 * 0.67 ≈ 2
                Text(teacher.name)
                    .font(.system(size: 13.3, weight: .semibold)) // headline ≈ 17pt, 17 * 0.67 ≈ 11.3
                    .lineLimit(1)
                
                Text("Уроків: \(teacher.lessons.count)")
                    .font(.system(size: 11.3)) // subheadline ≈ 14pt, 14 * 0.67 ≈ 9.3
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(currentMonthString.uppercased())
                    .font(.system(size: 9.3, weight: .medium)) // caption2 ≈ 11pt, 11 * 0.67 ≈ 7.3
                    .foregroundColor(.gray)
                
                Text(balance, format: .currency(code: "UAH"))
                    .font(.system(size: 13.3, weight: .bold)) // title3 ≈ 20pt, 20 * 0.67 ≈ 13.3
                    .foregroundColor(isOwed ? .red : .green)
            }
            .padding(.vertical, 5) // 8 * 0.67 ≈ 5
            .padding(.horizontal, 8) // 12 * 0.67 ≈ 8
            .background(
                RoundedRectangle(cornerRadius: 5) // 8 * 0.67 ≈ 5
                    .fill(isOwed ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
            )
        }
        .padding(.vertical, 2) // 4 * 0.67 ≈ 2
    }
}
