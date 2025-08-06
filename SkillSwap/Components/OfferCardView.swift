//
//  OfferCardView.swift
//  SkillSwap
//
//  Created by Niklesh Fernando on 2025-04-20.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct OfferCardView: View {
    var offer: Offer

    @State private var skillTopic: String = "..."
    @State private var skillOwnerName: String = "..."
    @State private var selectedGradient: [Color] = []
    @State private var showToast = false
    @State private var showSkillPicker = false
    @State private var userSkills: [Skill] = []

    let availableGradients: [[Color]] = [
        [Color.red, Color.orange],
        [Color.blue, Color.cyan],
        [Color.purple, Color.pink],
        [Color.green, Color.teal],
        [Color.indigo, Color.mint],
        [Color.yellow, Color.orange]
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🎓 I want to learn: \(offer.wantToLearn)")
                .font(.title3.bold())
                .foregroundColor(.white)

            Text("🛠️ I will teach: \(skillTopic)")
                .font(.headline)
                .foregroundColor(.white.opacity(0.95))

            Text(offer.description)
                .font(.body)
                .foregroundColor(.white.opacity(0.85))
                .padding(.top, 4)

            Divider().background(Color.white.opacity(0.4))

            HStack {
                Label(skillOwnerName, systemImage: "person.crop.circle.fill")
                    .font(.subheadline)
                    .foregroundColor(.white)

                Spacer()

                Button {
                    fetchUserSkills()
                    showSkillPicker = true
                } label: {
                    Text("Apply")
                        .font(.headline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(Color.white.opacity(0.8), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .frame(maxWidth: 600)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(LinearGradient(colors: selectedGradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal)
        .padding(.vertical, 8)
        .onAppear {
            fetchSkillAndOwner()
            assignRandomGradientOnce()
        }
        .sheet(isPresented: $showSkillPicker) {
            NavigationStack {
                List(userSkills) { skill in
                    Button {
                        applyToOffer(with: skill.id)
                        showSkillPicker = false
                    } label: {
                        Text(skill.topic)
                            .padding()
                    }
                }
                .navigationTitle("Choose a Skill")
            }
            .frame(minWidth: 400, minHeight: 300)
        }
        .overlay(
            VStack {
                if showToast {
                    Text("✅ Successfully Applied!")
                        .font(.callout)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .transition(.opacity)
                        .zIndex(1)
                }
                Spacer()
            }
            .padding(.top, 12),
            alignment: .top
        )
    }

    func assignRandomGradientOnce() {
        if selectedGradient.isEmpty {
            selectedGradient = availableGradients.randomElement() ?? [Color.gray, Color.gray.opacity(0.5)]
        }
    }

    func fetchSkillAndOwner() {
        let db = Firestore.firestore()

        db.collection("skills").document(offer.offeredSkillID).getDocument { skillSnapshot, error in
            if let error = error {
                print("Failed to fetch skill: \(error.localizedDescription)")
                return
            }

            guard let skillData = skillSnapshot?.data(),
                  let topic = skillData["topic"] as? String,
                  let skillUserID = skillData["userID"] as? String else {
                print("Missing skill fields")
                return
            }

            self.skillTopic = topic

            db.collection("users").document(skillUserID).getDocument { userSnapshot, error in
                if let error = error {
                    print("Failed to fetch user: \(error.localizedDescription)")
                    return
                }

                if let userData = userSnapshot?.data(),
                   let name = userData["fullname"] as? String {
                    self.skillOwnerName = name
                }
            }
        }
    }

    func fetchUserSkills() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("skills")
            .whereField("userID", isEqualTo: uid)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else { return }
                self.userSkills = docs.map {
                    Skill(
                        id: $0.documentID,
                        topic: $0["topic"] as? String ?? "Untitled",
                        description: $0["description"] as? String ?? ""
                    )
                }
            }
    }

    func applyToOffer(with skillID: String) {
        let db = Firestore.firestore()
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        db.collection("offers").document(offer.id).updateData([
            "status": "applied",
            "appliedBy": currentUserID,
            "appliedSkillID": skillID
        ]) { error in
            if let error = error {
                print("Failed to apply: \(error.localizedDescription)")
            } else {
                print("✅ Offer applied with skill ID \(skillID)")
                showToast = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        showToast = false
                    }
                }
            }
        }
    }
}


