//
//  SettingsRawView.swift
//  SkillSwap
//
//  Created by Niklesh Fernando on 2025-04-17.
//

import SwiftUI

struct SettingsRawView: View {
    let imageName: String
    let title: String
    let tintColor: Color
    var body: some View {
        HStack(spacing: 12){
            Image(systemName:imageName)
                .imageScale(.small)
                .font(.title)
                .foregroundColor(tintColor)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.black)
            
        }
    }
}

#Preview {
    SettingsRawView(imageName: "gear", title: "Version", tintColor: Color(.systemGray))
}
