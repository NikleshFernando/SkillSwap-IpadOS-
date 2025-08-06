//
//  Exchange.swift
//  SkillSwap
//
//  Created by Niklesh Fernando on 2025-04-16.
//
import SwiftUI
import FirebaseFirestore

// MARK: - Combined Offer + User Struct
struct OfferWithUser: Identifiable {
    var id: String { offer.id }
    let offer: Offer
    let userName: String
}

struct Exchange: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var myPendingOffers: [OfferWithUser] = []
    @State private var offersToAccept: [OfferWithUser] = []
    @State private var mySkillIDs: [String] = []
    @State private var selectedTab: ExchangeTab = .pending

    enum ExchangeTab: String, CaseIterable {
        case pending = "My Offers"
        case toAccept = "Offers To Accept"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // MARK: - Segmented Tab Picker
                Picker("Tab", selection: $selectedTab) {
                    ForEach(ExchangeTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // MARK: - Content Area
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        if selectedTab == .pending {
                            SectionTitle("My Pending Offers")
                            if myPendingOffers.isEmpty {
                                EmptyMessage("You have not applied to any offers.")
                            } else {
                                ForEach(myPendingOffers) { item in
                                    OfferCard(item: item, type: .pending) {
                                        deleteMyPendingOffer(item.offer)
                                    }
                                }
                            }
                        } else {
                            SectionTitle("Offers To Accept")
                            if offersToAccept.isEmpty {
                                EmptyMessage("No offers to accept right now.")
                            } else {
                                ForEach(offersToAccept) { item in
                                    OfferCard(item: item, type: .toAccept,
                                              onAccept: { acceptOffer(item.offer) },
                                              onReject: { rejectOffer(item.offer) })
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .padding(.top)
            .navigationTitle("Exchange")
            .onAppear {
                loadMySkillsAndOffers()
            }
        }
    }

    // MARK: - Section Title
    @ViewBuilder
    func SectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title2.bold())
            .padding(.bottom, 6)
    }

    // MARK: - Empty Message
    @ViewBuilder
    func EmptyMessage(_ text: String) -> some View {
        Text(text)
            .foregroundColor(.gray)
            .padding()
    }

    // MARK: - Offer Card
    enum CardType { case pending, toAccept }

    @ViewBuilder
    func OfferCard(item: OfferWithUser, type: CardType, onAccept: (() -> Void)? = nil, onReject: (() -> Void)? = nil, onDelete: (() -> Void)? = nil) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(type == .pending ? "To: \(item.userName)" : "\(item.userName) wants to learn:")
                .font(.headline)

            Text(item.offer.wantToLearn)
                .font(.title3.bold())

            Text("Will teach: \(item.offer.description)")
                .foregroundColor(.secondary)

            if type == .toAccept {
                HStack {
                    Button("Accept") { onAccept?() }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)

                    Button("Reject") { onReject?() }
                        .buttonStyle(.bordered)
                        .tint(.red)
                }
            } else {
                Button(role: .destructive) {
                    onDelete?()
                } label: {
                    Label("Delete Offer", systemImage: "trash")
                }
                .font(.footnote)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(radius: 3)
    }

    // MARK: - Firebase Operations

    func loadMySkillsAndOffers() {
        guard let uid = viewModel.currentUser?.id else { return }
        let db = Firestore.firestore()

        // Get my skill IDs
        db.collection("skills")
            .whereField("userID", isEqualTo: uid)
            .getDocuments { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                mySkillIDs = docs.map { $0.documentID }

                // Fetch offers to accept
                db.collection("offers")
                    .whereField("status", isEqualTo: "applied")
                    .getDocuments { offerSnap, _ in
                        guard let offerDocs = offerSnap?.documents else { return }
                        let filtered = offerDocs.compactMap {
                            let offer = Offer(document: $0)
                            return offer != nil && mySkillIDs.contains(offer!.offeredSkillID) ? offer : nil
                        }
                        fetchUserNames(for: filtered, isPending: false)
                    }
            }

        // Fetch my pending offers
        db.collection("offers")
            .whereField("appliedBy", isEqualTo: uid)
            .whereField("status", isEqualTo: "applied")
            .getDocuments { snap, _ in
                guard let docs = snap?.documents else { return }
                let offers = docs.compactMap { Offer(document: $0) }
                fetchUserNames(for: offers, isPending: true)
            }
    }

    func fetchUserNames(for offers: [Offer], isPending: Bool) {
        let db = Firestore.firestore()
        var offerWithUsers: [OfferWithUser] = []
        let group = DispatchGroup()

        for offer in offers {
            group.enter()
            db.collection("users").document(offer.userID).getDocument { snap, _ in
                let name = snap?.data()?["fullname"] as? String ?? "Unknown"
                offerWithUsers.append(OfferWithUser(offer: offer, userName: name))
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if isPending {
                myPendingOffers = offerWithUsers
            } else {
                offersToAccept = offerWithUsers
            }
        }
    }

    func acceptOffer(_ offer: Offer) {
        guard let uid = viewModel.currentUser?.id else { return }
        Firestore.firestore().collection("offers").document(offer.id).updateData([
            "status": "accepted",
            "acceptedBy": uid
        ]) { error in
            if error == nil {
                withAnimation {
                    offersToAccept.removeAll { $0.offer.id == offer.id }
                }
            }
        }
    }

    func rejectOffer(_ offer: Offer) {
        Firestore.firestore().collection("offers").document(offer.id).delete { error in
            if error == nil {
                withAnimation {
                    offersToAccept.removeAll { $0.offer.id == offer.id }
                }
            }
        }
    }

    func deleteMyPendingOffer(_ offer: Offer) {
        Firestore.firestore().collection("offers").document(offer.id).delete { error in
            if error == nil {
                withAnimation {
                    myPendingOffers.removeAll { $0.offer.id == offer.id }
                }
            }
        }
    }
}

#Preview {
    Exchange().environmentObject(AuthViewModel())
}

