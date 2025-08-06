//
//  CustomTabBar.swift
//  SkillSwap
//
//  Created by Niklesh Fernando on 2025-04-17.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case home = "house"
    case explore = "magnifyingglass.circle"
    case mycourse = "checkmark.message"
    case exchange = "play"
    case profile = "person"

    var tabName: String {
        switch self {
        case .home: return "Home"
        case .explore: return "Explore"
        case .mycourse: return "MyCourses"
        case .exchange: return "Exchange"
        case .profile: return "Profile"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab

    var body: some View {
        VStack {
            HStack {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    Spacer(minLength: 30)
                    VStack(spacing: 8) {
                        Image(systemName: selectedTab == tab ? tab.rawValue + ".fill" : tab.rawValue)
                            .scaleEffect(selectedTab == tab ? 1.3 : 1.0)
                            .foregroundColor(selectedTab == tab ? .accentColor : .gray)
                            .font(.system(size: 30))
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedTab = tab
                                }
                            }

                        Text(tab.tabName)
                            .font(.title3)
                            .foregroundColor(selectedTab == tab ? .accentColor : .gray)
                    }
                    Spacer(minLength: 30)
                }
            }
            .padding(.vertical, 20)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .padding(.horizontal, 60)
            .shadow(radius: 5)
        }
    }
}

#Preview {
    CustomTabBar(selectedTab: .constant(.home))
        .previewLayout(.sizeThatFits)
        .padding()
}
