//
//  SplashView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 31.10.2025.
//
import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var opacity: Double = 0.0
    @State private var size = 0.8
    
    @EnvironmentObject var dataStore: DataStore
    
    var body: some View {
        if isActive {
            TeachersListView()
                .environmentObject(dataStore)
        } else {
            ZStack {
                // Gradient Background
                LinearGradient(
                    colors: [Color.appBackground, Color.cardBackground],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color.accentGreen.opacity(0.2))
                            .frame(width: 140, height: 140)
                        
                        Circle()
                            .fill(Color.accentGreen.opacity(0.3))
                            .frame(width: 110, height: 110)
                        
                        Image(systemName: "book.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.accentGreen)
                    }
                    
                    // App Name
                    VStack(spacing: 8) {
                        Text("LalaryTracker")
                            .font(.system(size: 36, weight: .heavy))
                            .foregroundColor(.textPrimary)
                        
                        Text("Облік уроків та платежів")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                    }
                }
                .scaleEffect(size)
                .opacity(opacity)
            }
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
