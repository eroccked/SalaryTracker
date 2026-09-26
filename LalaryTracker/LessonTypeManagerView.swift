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

    var sortedTypes: [LessonType] {
        dataStore.lessonTypes.sorted(by: { $0.name < $1.name })
    }

    var body: some View {
        NavigationStack {
            HeroScaffold {
                VStack(spacing: 22) {
                    HeroTitle(title: "Типи уроків", icon: "square.stack.fill")

                    VStack(spacing: 8) {
                        Text("Налаштовано типів")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.78))
                        Text("\(dataStore.lessonTypes.count)")
                            .font(.system(size: 46, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .padding(.top, 10)

                    Button { showingAddSheet = true } label: {
                        Label("Новий тип", systemImage: "plus")
                    }
                    .buttonStyle(PillButtonStyle())
                }
            } panel: {
                VStack(alignment: .leading, spacing: 4) {
                    SectionHeader(title: "Базові ставки")

                    if sortedTypes.isEmpty {
                        EmptyStateView(
                            icon: "square.stack",
                            title: "Немає типів",
                            message: "Додайте тип уроку з базовою ставкою."
                        )
                    }

                    ForEach(Array(sortedTypes.enumerated()), id: \.element.id) { index, lessonType in
                        ListRow(
                            title: lessonType.name,
                            subtitle: "Базова ставка",
                            value: Fmt.money(lessonType.defaultRate),
                            caption: "за годину",
                            showsDivider: index < sortedTypes.count - 1
                        ) {
                            IconBadge(systemName: "tag.fill", tint: Color.chartPalette[index % Color.chartPalette.count])
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                dataStore.lessonTypes.removeAll { $0.id == lessonType.id }
                            } label: {
                                Label("Видалити", systemImage: "trash")
                            }
                        }
                    }

                    if !sortedTypes.isEmpty {
                        Text("Утримуйте тип, щоб видалити його.")
                            .font(.footnote)
                            .foregroundStyle(Color.inkSecondary)
                            .padding(.top, 12)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
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
        NavigationStack {
            Form {
                Section("Тип уроку") {
                    TextField("Назва (напр. «Індивідуальний»)", text: $typeName)
                }

                Section("Ставка") {
                    HStack {
                        Text("Базова ставка, ₴/год")
                        Spacer()
                        TextField("Ставка", value: $defaultRate, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .fontWeight(.semibold)
                    }
                }
            }
            .appFormStyle()
            .navigationTitle("Новий тип уроку")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Скасувати") { dismiss() }
                }
            }
            .primaryAction("Зберегти тип", isDisabled: typeName.trimmingCharacters(in: .whitespaces).isEmpty || defaultRate <= 0) {
                saveNewType()
            }
        }
    }

    func saveNewType() {
        let newType = LessonType(name: typeName.trimmingCharacters(in: .whitespaces), defaultRate: defaultRate)
        dataStore.lessonTypes.append(newType)
        dismiss()
    }
}
