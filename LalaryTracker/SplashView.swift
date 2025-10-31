//
//  SplashView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 31.10.2025.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var opacity: Double = 0.5
    @State private var size = 0.8
    
    @EnvironmentObject var dataStore: DataStore
    
    var body: some View {
        if isActive {
            TeachersListView()
                .environmentObject(dataStore)
        } else {
            VStack {
                Image(systemName: "clock.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.accentColor)
                
                Text("LalaryTracker")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(.primary)
            }
            .scaleEffect(size)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 1.2)) {
                    self.size = 1.0
                    self.opacity = 1.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}
