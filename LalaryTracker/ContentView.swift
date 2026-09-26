//
//  ContentView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 30.10.2025.
//
import SwiftUI

enum AppTab: Hashable {
    case teachers, transactions, lessons, types
}

enum QuickSheet: String, Identifiable {
    case lesson, payment, teacher
    var id: Self { self }
}

struct ContentView: View {
    @EnvironmentObject var dataStore: DataStore

    @State private var selectedTab: AppTab = .teachers
    @State private var showingAddMenu = false
    @State private var quickSheet: QuickSheet?

    var body: some View {
        TabView(selection: $selectedTab) {
            TeachersListView(selectedTab: $selectedTab)
                .tag(AppTab.teachers)
                .toolbar(.hidden, for: .tabBar)

            TransactionHistoryView()
                .tag(AppTab.transactions)
                .toolbar(.hidden, for: .tabBar)

            UnpaidLessonsView()
                .tag(AppTab.lessons)
                .toolbar(.hidden, for: .tabBar)

            LessonTypeManagerView()
                .tag(AppTab.types)
                .toolbar(.hidden, for: .tabBar)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppTabBar(selection: $selectedTab) {
                showingAddMenu = true
            }
        }
        .confirmationDialog("Що додати?", isPresented: $showingAddMenu, titleVisibility: .visible) {
            Button("Урок") { quickSheet = .lesson }
            Button("Платіж") { quickSheet = .payment }
            Button("Викладача") { quickSheet = .teacher }
        }
        .sheet(item: $quickSheet) { sheet in
            QuickSheetView(sheet: sheet)
                .environmentObject(dataStore)
        }
    }
}

// MARK: - QuickSheetView
struct QuickSheetView: View {
    let sheet: QuickSheet
    var teacherID: UUID? = nil

    var body: some View {
        switch sheet {
        case .lesson:
            AddLessonView(teacherID: teacherID)
        case .payment:
            AddPaymentView(teacherID: teacherID)
        case .teacher:
            AddTeacherView()
        }
    }
}

// MARK: - AppTabBar
struct AppTabBar: View {
    @Binding var selection: AppTab
    let onAdd: () -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            item(.teachers, title: "Головна", icon: "house")
            item(.transactions, title: "Транзакції", icon: "wallet.bifold")
            addButton
            item(.lessons, title: "Уроки", icon: "book.closed")
            item(.types, title: "Типи", icon: "square.stack")
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
        .background {
            UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28, style: .continuous)
                .fill(Color.surface)
                .shadow(color: .black.opacity(0.07), radius: 16, y: -4)
                .ignoresSafeArea(edges: .bottom)
        }
    }

    private func item(_ tab: AppTab, title: String, icon: String) -> some View {
        let isSelected = selection == tab
        return Button {
            selection = tab
        } label: {
            VStack(spacing: 5) {
                Image(systemName: isSelected ? "\(icon).fill" : icon)
                    .font(.system(size: 20, weight: .medium))
                    .frame(height: 24)
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(isSelected ? Color.ink : Color.inkSecondary)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var addButton: some View {
        Button(action: onAdd) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 62, height: 62)
                .background(AppGradient.accent, in: Circle())
                .overlay(Circle().stroke(Color.surface, lineWidth: 5))
                .shadow(color: Color.brand.opacity(0.4), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Додати")
        .frame(maxWidth: .infinity)
        .offset(y: -18)
        .padding(.bottom, -14)
    }
}
