//
//  SkillSwapApp.swift
//  SkillSwap
//
//  Created by Niklesh Fernando on 2025-04-15.
//

import SwiftUI
import Firebase
import FirebaseAuth


@main
struct SkillSwapApp: App {
    
    @StateObject var viewModel = AuthViewModel()
    
    init(){
        FirebaseApp.configure()
        
        #if targetEnvironment(simulator)
        AppCheck.setAppCheckProviderFactory(DebugAppCheckProviderFactory())
        #endif

        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        

    }
    var body: some Scene {
        WindowGroup {
            ThemedRootView()
                .environmentObject(viewModel)
        }
    }
}
