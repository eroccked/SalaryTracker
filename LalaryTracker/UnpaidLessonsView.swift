//
//  UnpaidLessonsView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 05.11.2025.
//

import SwiftUI

struct UnpaidLessonsView: View {
    @EnvironmentObject var dataStore: DataStore

    @State private var month = Date()

    struct LessonWithTeacher: Identifiable {
        var id: UUID { lesson.id }
        let lesson: Lesson
        let teacherName: String
    }

    var lessonsForMonth: [LessonWithTeacher] {
        dataStore.teachers
            .flatMap { teacher in
                teacher.lessons.map { LessonWithTeacher(lesson: $0, teacherName: teacher.name) }
            }
            .filter { $0.lesson.date.isSameMonth(as: month) }
            .sorted(by: { $0.lesson.date > $1.lesson.date })
    }

    var totalEarnedForMonth: Double {
        lessonsForMonth.reduce(0) { $0 + $1.lesson.cost }
    }

    var totalHoursForMonth: Double {
        lessonsForMonth.reduce(0) { $0 + $1.lesson.durationHours }
    }

    private var typeEntries: [DonutEntry] {
        Dictionary(grouping: lessonsForMonth, by: { $0.lesson.type.name })
            .map { (name, items) in (name, items.reduce(0) { $0 + $1.lesson.cost }) }
            .sorted { $0.1 > $1.1 }
            .enumerated()
            .map { index, pair in
                DonutEntry(label: pair.0, value: pair.1, color: Color.chartPalette[index % Color.chartPalette.count])
            }
    }

    var body: some View {
        NavigationStack {
            HeroScaffold {
                VStack(spacing: 22) {
                    HeroTitle(title: "Уроки", icon: "book.closed.fill")

                    VStack(spacing: 14) {
                        MonthSwitcher(date: $month)
                        HeroAmount(caption: "Зароблено за місяць", amount: totalEarnedForMonth)
                    }
                    .padding(.top, 10)

                    HStack(spacing: 8) {
                        HeroChip(icon: "book.closed", text: Fmt.lessons(lessonsForMonth.count))
                        HeroChip(icon: "timer", text: Fmt.hours(totalHoursForMonth))
                    }
                }
            } panel: {
                if lessonsForMonth.isEmpty {
                    EmptyStateView(
                        icon: "calendar",
                        title: "Немає уроків",
                        message: "Уроки за \(Fmt.month(month).lowercased()) відсутні."
                    )
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "За типами")
                        DonutStatCard(entries: typeEntries)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        SectionHeader(title: "Усі уроки", trailing: "\(lessonsForMonth.count)")

                        ForEach(lessonsForMonth) { item in
                            ListRow(
                                title: item.teacherName,
                                subtitle: "\(item.lesson.type.name) · \(Fmt.day(item.lesson.date))",
                                value: Fmt.money(item.lesson.cost),
                                caption: Fmt.hours(item.lesson.durationHours),
                                showsDivider: item.id != lessonsForMonth.last?.id
                            ) {
                                AvatarView(name: item.teacherName)
                            }
                        }
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}
