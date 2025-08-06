//
//  ThemedRootView.swift
//  SkillSwap
//
//  Created by Niklesh Fernando on 2025-06-28.
//

import SwiftUI

struct ThemedRootView: View {
    var body: some View {
        ZStack {
            // GLOBAL BACKGROUND
            LinearGradient(
                gradient: Gradient(colors: [Color.indigo.opacity(0.2), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // MAIN VIEW ENTRY POINT
            ContentView() // Or your main HomeView / SplitView
        }
    }
}

#Preview {
    ThemedRootView()
}
