//
//  TeacherDetailsView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 30.10.2025.
//
import SwiftUI

struct TeacherDetailsView: View {
    @Binding var teacher: Teacher
    @EnvironmentObject var dataStore: DataStore

    @State private var month = Date()
    @State private var quickSheet: QuickSheet?
    @State private var showingStatsSheet = false
    @State private var editingLesson: Lesson?
    @State private var editingPayment: Payment?

    // MARK: - Обчислювальні Властивості

    // Уроки за обраний місяць
    var monthLessons: [Lesson] {
        teacher.lessons
            .filter { $0.date.isSameMonth(as: month) }
            .sorted(by: { $0.date > $1.date })
    }

    // Платежі за обраний місяць
    var monthPayments: [Payment] {
        teacher.payments
            .filter { $0.date.isSameMonth(as: month) }
            .sorted(by: { $0.date > $1.date })
    }

    var monthlyEarned: Double {
        teacher.totalEarned(for: month)
    }

    var monthlyPaid: Double {
        teacher.totalPayments(for: month)
    }

    var monthlyBalance: Double {
        monthlyEarned - monthlyPaid
    }

    // MARK: - Функції

    func deleteLesson(_ lesson: Lesson) {
        teacher.lessons.removeAll { $0.id == lesson.id }
    }

    func deletePayment(_ payment: Payment) {
        teacher.payments.removeAll { $0.id == payment.id }
    }

    // MARK: - Body View

    var body: some View {
        HeroScaffold {
            hero
        } panel: {
            statistics
            paymentsSection
            lessonsSection
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingStatsSheet = true
                } label: {
                    Label("Статистика", systemImage: "chart.pie.fill")
                }
            }
        }
        .tint(.white)
        .sheet(item: $quickSheet) { sheet in
            QuickSheetView(sheet: sheet, teacherID: teacher.id)
                .environmentObject(dataStore)
        }
        .sheet(isPresented: $showingStatsSheet) {
            TeacherStatisticsView(teacher: teacher)
        }
        .sheet(item: $editingLesson) { lesson in
            EditLessonView(lesson: lesson) { updated in
                if let index = teacher.lessons.firstIndex(where: { $0.id == updated.id }) {
                    teacher.lessons[index] = updated
                }
            } onDelete: {
                deleteLesson(lesson)
            }
            .environmentObject(dataStore)
        }
        .sheet(item: $editingPayment) { payment in
            EditPaymentView(payment: payment) { updated in
                if let index = teacher.payments.firstIndex(where: { $0.id == updated.id }) {
                    teacher.payments[index] = updated
                }
            } onDelete: {
                deletePayment(payment)
            }
        }
    }

    // MARK: - Hero

    private var hero: some View {
        VStack(spacing: 18) {
            AvatarView(name: teacher.name, size: 76)
                .overlay(Circle().stroke(.white.opacity(0.7), lineWidth: 3))

            Text(teacher.name)
                .font(.title2.bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            VStack(spacing: 10) {
                HeroAmount(
                    caption: teacher.currentBalance > 0 ? "Загальний борг" : "Загальний баланс",
                    amount: teacher.currentBalance
                )

                HStack(spacing: 8) {
                    HeroChip(icon: "arrow.down.left", text: Fmt.money(teacher.totalEarned))
                    HeroChip(icon: "arrow.up.right", text: Fmt.money(teacher.totalPaid))
                }
            }

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
            .padding(.top, 4)
        }
    }

    // MARK: - Statistics

    private var statistics: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Статистика", trailing: "Детальніше") {
                showingStatsSheet = true
            }

            MonthSwitcher(date: $month, style: .onSurface)
                .frame(maxWidth: .infinity)

            DonutStatCard(entries: [
                DonutEntry(label: "Зароблено", value: monthlyEarned, color: .brand),
                DonutEntry(label: "Виплачено", value: monthlyPaid, color: .positive)
            ])

            SummaryRow(
                title: "Баланс за місяць",
                value: Fmt.money(monthlyBalance),
                valueColor: monthlyBalance > 0 ? .owed : .positive
            )
        }
    }

    // MARK: - Payments

    private var paymentsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            SectionHeader(title: "Платежі", trailing: "\(monthPayments.count)")

            if monthPayments.isEmpty {
                Text("Платежів у цьому місяці немає")
                    .font(.subheadline)
                    .foregroundStyle(Color.inkSecondary)
                    .padding(.vertical, 12)
            } else {
                ForEach(monthPayments) { payment in
                    Button {
                        editingPayment = payment
                    } label: {
                        PaymentListRow(payment: payment, showsDivider: payment.id != monthPayments.last?.id)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            deletePayment(payment)
                        } label: {
                            Label("Видалити", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }

    // MARK: - Lessons

    private var lessonsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            SectionHeader(title: "Уроки", trailing: "\(monthLessons.count)")

            if monthLessons.isEmpty {
                Text("Уроків у цьому місяці немає")
                    .font(.subheadline)
                    .foregroundStyle(Color.inkSecondary)
                    .padding(.vertical, 12)
            } else {
                ForEach(monthLessons) { lesson in
                    Button {
                        editingLesson = lesson
                    } label: {
                        LessonListRow(lesson: lesson, showsDivider: lesson.id != monthLessons.last?.id)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            deleteLesson(lesson)
                        } label: {
                            Label("Видалити", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }
}
