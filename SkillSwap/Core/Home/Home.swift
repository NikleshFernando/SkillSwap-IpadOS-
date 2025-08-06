//
//  Home.swift
//  SkillSwap
//
//  Created by Niklesh Fernando on 2025-04-16.
//

import SwiftUI
import FirebaseFirestore

struct HomeView: View {
    @State private var offers: [Offer] = []
    @State private var navigateToUpload = false
    @State private var searchText: String = ""

    var filteredOffers: [Offer] {
        if searchText.isEmpty {
            return offers
        } else {
            return offers.filter {
                $0.wantToLearn.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome to")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Text("SkillSwap")
                            .font(.largeTitle.bold())
                    }
                    Spacer()
                    Button {
                        navigateToUpload = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                TextField("Search skills or offers...", text: $searchText)
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding(.horizontal)

                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 350), spacing: 24)], spacing: 24) {
                        if filteredOffers.isEmpty {
                            Text("No offers available.")
                                .font(.title3)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                        } else {
                            ForEach(filteredOffers) { offer in
                                OfferCardView(offer: offer)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 16).fill(.thinMaterial))
                                    .shadow(radius: 4)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .padding(.top, 20)
            .navigationDestination(isPresented: $navigateToUpload) {
                OfferPost()
            }
            .onAppear {
                fetchOffers()
            }
        }
    }

    func fetchOffers() {
        let db = Firestore.firestore()
        db.collection("offers")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Failed to load offers: \(error.localizedDescription)")
                    return
                }

                guard let docs = snapshot?.documents else { return }
                self.offers = docs.compactMap { Offer(document: $0) }
            }
    }
}

#Preview {
    HomeView()
        .previewInterfaceOrientation(.landscapeLeft)
        .previewDevice("iPad Pro (11-inch) (6th generation)")
}

