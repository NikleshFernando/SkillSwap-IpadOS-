//
//  Profile.swift
//  SkillSwap
//

import SwiftUI
import FirebaseFirestore

struct Profile: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var userSkills: [Skill] = []
    @State private var userOffers: [Offer] = []
    @State private var showAddSkill = false
    @State private var selectedTab: ProfileTab = .skills

    enum ProfileTab: String, CaseIterable {
        case skills = "My Skills"
        case offers = "My Offers"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: - User Info
                    if let user = viewModel.currentUser {
                        HStack(spacing: 20) {
                            Text(user.initials)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 80, height: 80)
                                .background(Color.blue)
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.fullname)
                                    .font(.title2.bold())
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Button {
                                showAddSkill = true
                            } label: {
                                Label("Add Skill", systemImage: "plus.circle.fill")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)

                        // MARK: - Tabs
                        Picker("Tab", selection: $selectedTab) {
                            ForEach(ProfileTab.allCases, id: \.self) { tab in
                                Text(tab.rawValue).tag(tab)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)

                        // MARK: - Content
                        if selectedTab == .skills {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("My Skills")
                                    .font(.headline)
                                    .padding(.horizontal)

                                if userSkills.isEmpty {
                                    Text("No skills added yet.")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal)
                                } else {
                                    ForEach(userSkills) { skill in
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(skill.topic)
                                                .font(.title3.bold())
                                            Text(skill.description)
                                                .foregroundColor(.secondary)

                                            Button(role: .destructive) {
                                                deleteSkill(skill)
                                            } label: {
                                                Label("Delete Skill", systemImage: "trash")
                                                    .font(.footnote)
                                            }
                                        }
                                        .padding()
                                        .background(.thinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .shadow(radius: 2)
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("My Offers")
                                    .font(.headline)
                                    .padding(.horizontal)

                                if userOffers.isEmpty {
                                    Text("No offers made yet.")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal)
                                } else {
                                    ForEach(userOffers) { offer in
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text("Learn: \(offer.wantToLearn)")
                                                .font(.title3.bold())
                                            Text("Teach: \(offer.description)")
                                                .foregroundColor(.secondary)

                                            Button(role: .destructive) {
                                                deleteOffer(offer)
                                            } label: {
                                                Label("Delete Offer", systemImage: "trash")
                                                    .font(.footnote)
                                            }
                                        }
                                        .padding()
                                        .background(.thinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .shadow(radius: 2)
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }

                        // MARK: - General & Account
                        VStack(spacing: 10) {
                            Divider().padding(.top)

                            HStack {
                                Label("App Version", systemImage: "gear")
                                Spacer()
                                Text("1.0.0")
                                    .foregroundColor(.secondary)
                            }

                            Divider()

                            Button {
                                viewModel.signOut()
                            } label: {
                                Label("Sign Out", systemImage: "arrow.left.circle.fill")
                                    .foregroundColor(.red)
                            }

                            Button(role: .destructive) {
                                Task {
                                    await viewModel.deleteAccount()
                                }
                            } label: {
                                Label("Delete Account", systemImage: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    } else {
                        ProgressView("Loading...")
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showAddSkill) {
                SkillUpload()
            }
            .onAppear {
                if let user = viewModel.currentUser {
                    fetchUserSkills(userID: user.id)
                    fetchUserOffers(userID: user.id)
                }
            }
        }
    }

    // MARK: - Firestore Methods
    func fetchUserSkills(userID: String) {
        Firestore.firestore().collection("skills")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents, error == nil else { return }
                userSkills = docs.map {
                    Skill(
                        id: $0.documentID,
                        topic: $0["topic"] as? String ?? "Untitled",
                        description: $0["description"] as? String ?? ""
                    )
                }
            }
    }

    func fetchUserOffers(userID: String) {
        Firestore.firestore().collection("offers")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents, error == nil else { return }
                userOffers = docs.compactMap { Offer(document: $0) }
            }
    }

    func deleteSkill(_ skill: Skill) {
        Firestore.firestore().collection("skills").document(skill.id).delete { error in
            if error == nil {
                userSkills.removeAll { $0.id == skill.id }
            }
        }
    }

    func deleteOffer(_ offer: Offer) {
        Firestore.firestore().collection("offers").document(offer.id).delete { error in
            if error == nil {
                userOffers.removeAll { $0.id == offer.id }
            }
        }
    }
}

#Preview {
    Profile()
        .environmentObject(AuthViewModel())
        .previewDevice("iPad Pro (11-inch) (6th generation)")
}

