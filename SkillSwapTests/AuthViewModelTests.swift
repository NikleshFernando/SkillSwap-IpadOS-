//
//  AuthViewModelTests.swift
//  SkillSwapTests
//
//  Created by Niklesh Fernando on 2025-05-04.
//

import XCTest
@testable import SkillSwap

@MainActor
final class AuthViewModelTests: XCTestCase {

    func testFetchUserWhenNoUserSession() async {
        let viewModel = AuthViewModel()
        
        // Simulate no logged-in user
        viewModel.userSession = nil
        
        await viewModel.fetchUser()
        
        XCTAssertNil(viewModel.currentUser, "Expected currentUser to be nil when no session exists")
    }
}

