//
//  ContentView.swift
//  SkillSwap
//
//  Created by Niklesh Fernando on 2025-04-15.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @EnvironmentObject var viewModel: AuthViewModel
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        Group {
            if viewModel.userSession != nil {
                ZStack {
                    switch selectedTab {
                    case .home:
                        HomeView()
                    case .explore:
                        Explore()
                    case .mycourse:
                        MyCourses()
                    case .exchange:
                        Exchange()
                    case .profile:
                        Profile()
                    }
                    
                    VStack {
                        Spacer()
                        CustomTabBar(selectedTab: $selectedTab)
                    }
                }
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}

