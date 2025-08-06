//
//  Explore.swift
//  SkillSwap
//
//  Created by Niklesh Fernando on 2025-04-16.
//

import SwiftUI
import FirebaseFirestore

struct Explore: View {
    @State private var allOffers: [Offer] = []
    @State private var enrichedOffers: [Offer] = []
    @State private var searchText: String = ""
    @State private var isLoading: Bool = true
    @EnvironmentObject var viewModel: AuthViewModel

    var filteredOffers: [Offer] {
        if searchText.isEmpty {
            return enrichedOffers
        } else {
            return enrichedOffers.filter {
                $0.wantToLearn.lowercased().contains(searchText.lowercased()) ||
                $0.userName.lowercased().contains(searchText.lowercased())
            }
        }
    }

    let columns = [GridItem(.adaptive(minimum: 320), spacing: 24)]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                // MARK: - Header
                HStack {
                    Text("Explore Skill Offers")
                        .font(.largeTitle.bold())
                    Spacer()
                }
                .padding(.horizontal)

                // MARK: - Search Bar
                TextField("Search by user or skill...", text: $searchText)
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding(.horizontal)

                // MARK: - Content
                if isLoading {
                    Spacer()
                    ProgressView("Loading offers...")
                    Spacer()
                } else if filteredOffers.isEmpty {
                    Spacer()
                    Text("No offers found.")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 24) {
                            ForEach(filteredOffers) { offer in
                                OfferCardView(offer: offer)
                                    .padding()
                                    .background(.thinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .shadow(radius: 4)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }
            }
            .padding(.top)
            .navigationTitle("Explore")
            .onAppear {
                if enrichedOffers.isEmpty {
                    fetchAllOffers()
                }
            }
        }
    }

    // MARK: - Fetch Offers
    func fetchAllOffers() {
        let db = Firestore.firestore()

        db.collection("offers")
            .whereField("status", isEqualTo: "pending")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching offers: \(error.localizedDescription)")
                    self.isLoading = false
                    return
                }

                guard let documents = snapshot?.documents else {
                    self.isLoading = false
                    return
                }

                let offers = documents.compactMap { Offer(document: $0) }
                self.allOffers = offers
                enrichOffersWithUsernames(offers)
            }
    }

    // MARK: - Add Usernames
    func enrichOffersWithUsernames(_ offers: [Offer]) {
        let db = Firestore.firestore()
        var enriched = offers
        let group = DispatchGroup()

        for index in enriched.indices {
            group.enter()
            let userID = enriched[index].userID

            db.collection("users").document(userID).getDocument { snapshot, _ in
                if let data = snapshot?.data(),
                   let name = data["fullname"] as? String {
                    enriched[index].userName = name
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.enrichedOffers = enriched
            self.isLoading = false
        }
    }
}

#Preview {
    Explore().environmentObject(AuthViewModel())
}

