//
//  TeacherListView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 30.10.2025.
//

import SwiftUI

struct TeachersListView: View {

    @EnvironmentObject var dataStore: DataStore
    @Binding var selectedTab: AppTab

    @State private var month = Date()
    @State private var quickSheet: QuickSheet?
    @State private var teacherToDelete: Teacher?

    // MARK: - Місячні підсумки по всіх викладачах

    var monthEarned: Double {
        dataStore.teachers.reduce(0) { $0 + $1.totalEarned(for: month) }
    }

    var monthPaid: Double {
        dataStore.teachers.reduce(0) { $0 + $1.totalPayments(for: month) }
    }

    var monthDebt: Double {
        monthEarned - monthPaid
    }

    var body: some View {
        NavigationStack {
            HeroScaffold {
                hero
            } panel: {
                quickActions
                teachersSection
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $quickSheet) { sheet in
                QuickSheetView(sheet: sheet)
                    .environmentObject(dataStore)
            }
            .confirmationDialog(
                "Видалити викладача?",
                isPresented: Binding(
                    get: { teacherToDelete != nil },
                    set: { if !$0 { teacherToDelete = nil } }
                ),
                titleVisibility: .visible,
                presenting: teacherToDelete
            ) { teacher in
                Button("Видалити «\(teacher.name)»", role: .destructive) {
                    dataStore.teachers.removeAll { $0.id == teacher.id }
                }
            } message: { _ in
                Text("Усі уроки та платежі цього викладача буде видалено.")
            }
        }
    }

    // MARK: - Hero

    private var hero: some View {
        VStack(spacing: 22) {
            HeroTitle(title: "LalaryTracker", icon: "graduationcap.fill")

            VStack(spacing: 14) {
                MonthSwitcher(date: $month)
                HeroAmount(caption: "Зароблено за місяць", amount: monthEarned)
            }
            .padding(.top, 10)

            HStack(spacing: 14) {
                Button { quickSheet = .lesson } label: {
                    Label("Урок", systemImage: "plus")
                }
                .buttonStyle(PillButtonStyle())

                Button { quickSheet = .payment } label: {
                    Label("Платіж", systemImage: "arrow.up.right")
                }
                .buttonStyle(PillButtonStyle())
            }

            if monthDebt > 0 {
                InfoStrip(
                    icon: "exclamationmark",
                    text: "До виплати \(Fmt.money(monthDebt))",
                    buttonTitle: "Уроки"
                ) {
                    selectedTab = .lessons
                }
            } else if monthEarned > 0 {
                InfoStrip(icon: "checkmark", text: "За цей місяць усе виплачено")
            }
        }
    }

    // MARK: - Quick Actions

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Швидкі дії")

            HStack(spacing: 12) {
                QuickActionTile(title: "Викладач", icon: "person.badge.plus", background: AppGradient.lavender, tint: .brand) {
                    quickSheet = .teacher
                }
                QuickActionTile(title: "Уроки", icon: "book.closed.fill", background: AppGradient.peach, tint: Color(hex: "D9804F")) {
                    selectedTab = .lessons
                }
                QuickActionTile(title: "Транзакції", icon: "wallet.bifold.fill", background: AppGradient.mint, tint: .positive) {
                    selectedTab = .transactions
                }
            }
        }
    }

    // MARK: - Teachers

    private var teachersSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            SectionHeader(title: "Викладачі", trailing: dataStore.teachers.isEmpty ? nil : "\(dataStore.teachers.count)")

            if dataStore.teachers.isEmpty {
                EmptyStateView(
                    icon: "person.3.fill",
                    title: "Немає викладачів",
                    message: "Натисніть «Викладач» у швидких діях,\nщоб додати перший профіль."
                )
            } else {
                ForEach($dataStore.teachers) { $teacher in
                    NavigationLink {
                        TeacherDetailsView(teacher: $teacher)
                            .environmentObject(dataStore)
                    } label: {
                        TeacherRow(
                            teacher: teacher,
                            month: month,
                            showsDivider: teacher.id != dataStore.teachers.last?.id
                        )
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            teacherToDelete = teacher
                        } label: {
                            Label("Видалити", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }
}


struct TeacherRow: View {
    let teacher: Teacher
    let month: Date
    var showsDivider: Bool = true

    private var balance: Double {
        teacher.totalEarned(for: month) - teacher.totalPayments(for: month)
    }

    private var lessonsCount: Int {
        teacher.lessons.filter { $0.date.isSameMonth(as: month) }.count
    }

    private var caption: String {
        if balance > 0 { return "борг" }
        if balance < 0 { return "переплата" }
        return "сплачено"
    }

    var body: some View {
        ListRow(
            title: teacher.name,
            subtitle: "\(Fmt.lessons(lessonsCount)) · \(Fmt.month(month, withYear: false).lowercased())",
            value: Fmt.money(balance),
            valueColor: balance > 0 ? .owed : .ink,
            caption: caption,
            showsDivider: showsDivider
        ) {
            AvatarView(name: teacher.name)
        }
    }
}
