//
//  MyCourses.swift
//  SkillSwap
//
//  Created by Niklesh Fernando on 2025-04-21.
//

import SwiftUI
import FirebaseFirestore

struct MyCourses: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var acceptedSkills: [Skill] = []

    let columns = [GridItem(.adaptive(minimum: 350), spacing: 20)]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("My Accepted Courses")
                    .font(.largeTitle.bold())
                    .padding(.horizontal)

                if acceptedSkills.isEmpty {
                    Spacer()
                    Text("You haven’t accepted any skill offers yet.")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 24) {
                            ForEach(acceptedSkills) { skill in
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(skill.topic)
                                        .font(.title2.bold())

                                    Text(skill.description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)

                                    HStack(spacing: 12) {
                                        if let videoURL = skill.videoURL, let url = URL(string: videoURL) {
                                            Link("🎬 Watch Video", destination: url)
                                                .buttonStyle(.borderedProminent)
                                        }

                                        if let pdfURL = skill.pdfURL, let url = URL(string: pdfURL) {
                                            Link("📄 View PDF", destination: url)
                                                .buttonStyle(.bordered)
                                        }
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(radius: 3)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }
            }
            .padding(.top)
            .navigationTitle("My Courses")
            .onAppear {
                fetchAcceptedSkills()
            }
        }
    }

    // MARK: - Firestore Fetching
    func fetchAcceptedSkills() {
        guard let currentUserID = viewModel.currentUser?.id else { return }
        let db = Firestore.firestore()

        db.collection("offers")
            .whereField("appliedBy", isEqualTo: currentUserID)
            .whereField("status", isEqualTo: "accepted")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching accepted offers: \(error.localizedDescription)")
                    return
                }

                let skillIDs = snapshot?.documents.compactMap { $0["offeredSkillID"] as? String } ?? []
                fetchSkills(for: skillIDs)
            }
    }

    func fetchSkills(for ids: [String]) {
        guard !ids.isEmpty else { return }
        let db = Firestore.firestore()

        db.collection("skills")
            .whereField(FieldPath.documentID(), in: Array(ids.prefix(10)))
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching skills: \(error.localizedDescription)")
                    return
                }

                acceptedSkills = snapshot?.documents.compactMap { doc in
                    Skill(
                        id: doc.documentID,
                        topic: doc["topic"] as? String ?? "Untitled",
                        description: doc["description"] as? String ?? "",
                        videoURL: doc["videoURL"] as? String,
                        pdfURL: doc["pdfURL"] as? String
                    )
                } ?? []
            }
    }
}

#Preview {
    MyCourses()
        .environmentObject(AuthViewModel())
        .previewInterfaceOrientation(.landscapeLeft)
        .previewDevice("iPad Pro (11-inch) (6th generation)")
}
