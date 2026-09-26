//
//  SplashView.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 31.10.2025.
//
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var opacity: Double = 0.5
    @State private var size = 0.8

    @EnvironmentObject var dataStore: DataStore

    var body: some View {
        if isActive {
            ContentView()
                .environmentObject(dataStore)
        } else {
            ZStack {
                AppBackground()

                VStack(spacing: 18) {
                    Image("SplashLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 27, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 27, style: .continuous)
                                .stroke(.white.opacity(0.35), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 24, y: 12)

                    VStack(spacing: 6) {
                        Text("LalaryTracker")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Облік уроків і виплат")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .scaleEffect(size)
                .opacity(opacity)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.9)) {
                    self.size = 1.0
                    self.opacity = 1.0
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}
