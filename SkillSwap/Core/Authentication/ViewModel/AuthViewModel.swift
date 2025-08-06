//
//  AuthViewModel.swift
//  SkillSwap
//
//  Created by Niklesh Fernando on 2025-04-18.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}
@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?

    init() {
        self.userSession = Auth.auth().currentUser
        
        Task{
            await fetchUser()
        }
    }

    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print("⚠️ Sign in failed: \(error.localizedDescription)")
            throw error
        }
    }

    func createUser(withEmail email: String, passwowrd: String, fullname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: passwowrd)
            self.userSession = result.user
            
            let user = User(id: result.user.uid, fullname: fullname, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
        } catch {
            print("⚠️ Create user failed: \(error.localizedDescription)")
            throw error
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("⚠️ Sign out failed: \(error.localizedDescription)")
        }
    }

    func deleteAccount() {
        // Delete Logic not yet developed but in future willl be
    }

    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        
        self.currentUser = try? snapshot.data(as: User.self)
        
        print("Current user is \(self.currentUser)")
    }
}
