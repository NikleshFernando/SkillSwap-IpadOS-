//
//  RegistrationFormTest.swift
//  SkillSwapTests
//
//  Created by Niklesh Fernando on 2025-05-04.
//

import XCTest
@testable import SkillSwap

final class RegistrationFormTests: XCTestCase {

    struct DummyForm: AuthenticationFormProtocol {
        var email: String
        var password: String
        var confirmPassword: String
        var fullName: String

        var formIsValid: Bool {
            return !email.isEmpty
            && email.contains("@")
            && !password.isEmpty
            && password.count > 5
            && confirmPassword == password
            && !fullName.isEmpty
        }
    }

    func testValidForm() {
        let form = DummyForm(email: "test@example.com", password: "abcdef", confirmPassword: "abcdef", fullName: "Tester")
        XCTAssertTrue(form.formIsValid)
    }

    func testInvalidFormWhenEmailEmpty() {
        let form = DummyForm(email: "", password: "abcdef", confirmPassword: "abcdef", fullName: "Tester")
        XCTAssertFalse(form.formIsValid)
    }

    func testInvalidFormWhenPasswordsDoNotMatch() {
        let form = DummyForm(email: "test@example.com", password: "abcdef", confirmPassword: "123456", fullName: "Tester")
        XCTAssertFalse(form.formIsValid)
    }
}
