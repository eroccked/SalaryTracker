//
//  ContentView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 30.10.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TeachersListView()
                .tabItem {
                    Label("Викладачі", systemImage: "person.3.fill")
                }
            
            TransactionHistoryView()
                .tabItem {
                    Label("Транзакції", systemImage: "banknote.fill")
                }
        }
    }
}
