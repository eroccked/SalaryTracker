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
    @State private var teacherToDelete: Teacher?
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient Background like the reference
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
                        if dataStore.teachers.isEmpty {
                            VStack(spacing: 20) {
                                Spacer()
                                    .frame(height: 100)
                                
                                Image(systemName: "person.3.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.textSecondary)
                                
                                Text("Немає викладачів")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.textPrimary)
                                
                                Text("Натисніть '+' для додавання нового профілю")
                                    .font(.subheadline)
                                    .foregroundColor(.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                        } else {
                            ForEach(dataStore.teachers) { teacher in
                                NavigationLink {
                                    if let index = dataStore.teachers.firstIndex(where: { $0.id == teacher.id }) {
                                        TeacherDetailsView(teacher: $dataStore.teachers[index])
                                            .environmentObject(dataStore)
                                    }
                                } label: {
                                    TeacherRow(teacher: teacher)
                                        .padding(.horizontal)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .contextMenu {
                                    Button(role: .destructive) {
                                        teacherToDelete = teacher
                                        showingDeleteAlert = true
                                    } label: {
                                        Label("Видалити викладача", systemImage: "trash.fill")
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Викладачі")
            .tint(.textPrimary)
            .alert("Видалити викладача?", isPresented: $showingDeleteAlert) {
                Button("Скасувати", role: .cancel) { }
                Button("Видалити", role: .destructive) {
                    if let teacher = teacherToDelete,
                       let index = dataStore.teachers.firstIndex(where: { $0.id == teacher.id }) {
                        withAnimation {
                            dataStore.teachers.remove(at: index)
                        }
                    }
                    teacherToDelete = nil
                }
            } message: {
                if let teacher = teacherToDelete {
                    Text("Ви впевнені, що хочете видалити \(teacher.name)? Всі уроки та платежі будуть втрачені.")
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        showingTypeManagerSheet = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.textPrimary)
                    }
                    
                    Button {
                        showingUnpaidLessonsSheet = true
                    } label: {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.textPrimary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTeacherSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.accentGreen)
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
    
    var currentMonthBalance: Double {
        let now = Date()
        let earned = teacher.totalEarned(for: now)
        let paid = teacher.totalPayments(for: now)
        return earned - paid
    }
    
    var currentMonthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        formatter.locale = Locale(identifier: "uk_UA")
        return formatter.string(from: Date()).capitalized
    }
    
    var body: some View {
        let balance = currentMonthBalance
        let isOwed = balance > 0
        
        return HStack(alignment: .center, spacing: 15) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.accentGreen.opacity(0.15))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "person.fill")
                    .font(.title2)
                    .foregroundColor(.accentGreen)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(teacher.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Image(systemName: "book.fill")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    Text("Уроків: \(teacher.lessons.count)")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
                
                Text(currentMonthString.uppercased())
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(balance, format: .currency(code: "UAH"))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(isOwed ? .softRed : .accentGreen)
                
                Text(isOwed ? "Борг" : "Оплачено")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isOwed ? .softRed : .accentGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isOwed ? Color.softRed.opacity(0.2) : Color.accentGreen.opacity(0.1))
                    )
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
