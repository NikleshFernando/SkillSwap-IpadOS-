//
//  OfferPostView.swift
//  SkillSwap
//
//  Created by Niklesh Fernando on 2025-04-20.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import PencilKit

struct OfferPost: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel

    @State private var wantToLearn = ""
    @State private var selectedSkillID: String?
    @State private var description = ""
    @State private var userSkills: [Skill] = []
    @State private var isPosting = false
    @State private var showSuccessAlert = false

    // PencilKit
    @State private var showDrawingSheet = false
    @State private var canvasView = PKCanvasView()
    @State private var drawingImage: UIImage?
    @State private var uploadedDrawingURL: String?

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Predicted Category
                Section(header: Text("I want to learn")) {
                    TextField("e.g. Spanish, Coding, Guitar...", text: $wantToLearn)
                        .disabled(true)
                        .foregroundColor(.gray)

                    if !wantToLearn.isEmpty {
                        Text("Predicted: \(wantToLearn)")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }

                // MARK: - Skill Picker
                Section(header: Text("I will teach")) {
                    if userSkills.isEmpty {
                        Text("You haven't uploaded any skills yet.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    } else {
                        Picker("Select one of your skills", selection: $selectedSkillID) {
                            ForEach(userSkills) { skill in
                                Text(skill.topic).tag(skill.id as String?)
                            }
                        }
                    }
                }

                // MARK: - Description with ML
                Section(header: Text("Details")) {
                    TextEditor(text: Binding(
                        get: { description },
                        set: { newValue in
                            description = newValue
                            wantToLearn = SkillCategoryPredictor.shared.predictCategory(for: newValue)
                        }
                    ))
                    .frame(height: 100)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                }

                // MARK: - Optional Drawing
                Section(header: Text("Whiteboard Notes (Optional)")) {
                    Button("Open Drawing Canvas") {
                        showDrawingSheet = true
                    }

                    if let drawingImage = drawingImage {
                        Image(uiImage: drawingImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(10)
                    }

                    if let url = uploadedDrawingURL {
                        Link("📎 View uploaded sketch", destination: URL(string: url)!)
                    }
                }

                // MARK: - Submit
                Section {
                    Button("Post Offer") {
                        postOffer()
                    }
                    .disabled(wantToLearn.isEmpty || selectedSkillID == nil || isPosting)
                }
            }
            .navigationTitle("Create Offer")
            .onAppear {
                loadUserSkills()
            }
            .alert("Offer Posted!", isPresented: $showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            }
            .sheet(isPresented: $showDrawingSheet, onDismiss: saveDrawingAndUpload) {
                NavigationStack {
                    DrawingCanvasView(canvasView: $canvasView)
                        .navigationTitle("Sketch")
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") {
                                    showDrawingSheet = false
                                }
                            }
                        }
                }
            }
        }
    }

    // MARK: - Load Skills
    func loadUserSkills() {
        guard let userID = viewModel.currentUser?.id else { return }
        Firestore.firestore().collection("skills")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else { return }
                self.userSkills = docs.compactMap { Skill(document: $0) }
            }
    }

    // MARK: - Save Drawing Locally & Upload
    func saveDrawingAndUpload() {
        let image = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale)
        drawingImage = image

        guard let data = image.jpegData(compressionQuality: 0.7) else { return }

        let filename = UUID().uuidString + ".jpg"
        let ref = Storage.storage().reference().child("drawings/\(filename)")

        ref.putData(data, metadata: nil) { _, error in
            if let error = error {
                print("⚠️ Upload error: \(error.localizedDescription)")
                return
            }

            ref.downloadURL { url, error in
                if let url = url {
                    uploadedDrawingURL = url.absoluteString
                }
            }
        }
    }

    // MARK: - Post Offer
    func postOffer() {
        guard let userID = viewModel.currentUser?.id,
              let offeredSkillID = selectedSkillID else { return }

        isPosting = true

        var data: [String: Any] = [
            "userID": userID,
            "wantToLearn": wantToLearn,
            "offeredSkillID": offeredSkillID,
            "description": description,
            "createdAt": Timestamp()
        ]

        if let url = uploadedDrawingURL {
            data["drawingURL"] = url
        }

        Firestore.firestore().collection("offers").addDocument(data: data) { error in
            isPosting = false
            if let error = error {
                print("❌ Failed to post offer: \(error.localizedDescription)")
            } else {
                showSuccessAlert = true
                resetForm()
            }
        }
    }

    // MARK: - Reset
    func resetForm() {
        wantToLearn = ""
        selectedSkillID = nil
        description = ""
        drawingImage = nil
        uploadedDrawingURL = nil
        canvasView.drawing = PKDrawing()
    }
}



#Preview {
    OfferPost().environmentObject(AuthViewModel())
}

