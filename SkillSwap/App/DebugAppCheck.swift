//
//  DebugAppCheck.swift
//  SkillSwap
//
//  Created by Niklesh Fernando on 2025-06-27.
//

import FirebaseAppCheck
import FirebaseCore

class DebugAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        return AppCheckDebugProvider(app: app)
    }
}

