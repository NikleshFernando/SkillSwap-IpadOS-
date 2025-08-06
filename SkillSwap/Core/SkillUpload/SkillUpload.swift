//
//  SkillUpload.swift
//  SkillSwap
//
//  Created by Niklesh Fernando on 2025-04-19.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

struct SkillUpload: View {
    @State private var topic = ""
    @State private var description = ""
    @State private var videoURL: URL?
    @State private var pdfURL: URL?

    @State private var isShowingDocumentPicker = false
    @State private var currentPickerType: PickerType?

    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var isUploading = false
    @State private var uploadProgress: Double = 0.0

    @Environment(\.dismiss) var dismiss

    enum PickerType {
        case video, pdf
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Skill Information")) {
                    TextField("Skill Topic", text: $topic)
                    TextEditor(text: $description)
                        .frame(height: 100)
                }

                Section(header: Text("Teaching Video")) {
                    Button("Select Video") {
                        currentPickerType = .video
                        isShowingDocumentPicker = true
                    }
                    if let url = videoURL {
                        Text(url.lastPathComponent)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                Section(header: Text("Course PDF")) {
                    Button("Select PDF") {
                        currentPickerType = .pdf
                        isShowingDocumentPicker = true
                    }
                    if let url = pdfURL {
                        Text(url.lastPathComponent)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                if isUploading {
                    Section {
                        ProgressView(value: uploadProgress)
                        Text("Uploading...")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }

                Section {
                    Button("Upload Skill") {
                        uploadSkill()
                    }
                    .disabled(topic.isEmpty || description.isEmpty || videoURL == nil || pdfURL == nil || isUploading)
                }
            }
            .navigationTitle("Add Your Skill")
            .sheet(isPresented: $isShowingDocumentPicker) {
                if let pickerType = currentPickerType {
                    DocumentPicker(
                        allowedTypes: pickerType == .video ? ["public.movie"] : ["com.adobe.pdf"],
                        selectedURL: pickerType == .video ? $videoURL : $pdfURL
                    )
                }
            }
            .alert("Skill Uploaded Successfully!", isPresented: $showSuccessAlert) {
                Button("OK") { dismiss() }
            }
            .alert("Upload Failed", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    func uploadSkill() {
        guard let video = videoURL, let pdf = pdfURL else { return }
        guard let userID = Auth.auth().currentUser?.uid else {
            errorMessage = "User not logged in."
            showErrorAlert = true
            return
        }

        isUploading = true
        uploadProgress = 0.0

        let storage = Storage.storage()
        let db = Firestore.firestore()
        let skillID = UUID().uuidString

        let videoRef = storage.reference().child("skills/\(skillID)/video.mov")
        let pdfRef = storage.reference().child("skills/\(skillID)/material.pdf")

        var videoDownloadURL: URL?
        var pdfDownloadURL: URL?

        let dispatchGroup = DispatchGroup()

        do {
            let videoData = try Data(contentsOf: video)
            let pdfData = try Data(contentsOf: pdf)

            // Upload Video
            dispatchGroup.enter()
            videoRef.putData(videoData, metadata: nil) { _, error in
                if let error = error {
                    errorMessage = "Video upload failed: \(error.localizedDescription)"
                    showErrorAlert = true
                    isUploading = false
                    dispatchGroup.leave()
                    return
                }
                videoRef.downloadURL { url, _ in
                    videoDownloadURL = url
                    uploadProgress += 0.5
                    dispatchGroup.leave()
                }
            }

            // Upload PDF
            dispatchGroup.enter()
            pdfRef.putData(pdfData, metadata: nil) { _, error in
                if let error = error {
                    errorMessage = "PDF upload failed: \(error.localizedDescription)"
                    showErrorAlert = true
                    isUploading = false
                    dispatchGroup.leave()
                    return
                }
                pdfRef.downloadURL { url, _ in
                    pdfDownloadURL = url
                    uploadProgress += 0.5
                    dispatchGroup.leave()
                }
            }

        } catch {
            errorMessage = "Could not read file data: \(error.localizedDescription)"
            showErrorAlert = true
            isUploading = false
            return
        }

        // When both are done
        dispatchGroup.notify(queue: .main) {
            guard let videoURL = videoDownloadURL, let pdfURL = pdfDownloadURL else {
                isUploading = false
                return
            }

            let data: [String: Any] = [
                "userID": userID,
                "topic": topic,
                "description": description,
                "videoURL": videoURL.absoluteString,
                "pdfURL": pdfURL.absoluteString,
                "createdAt": Timestamp()
            ]

            db.collection("skills").document(skillID).setData(data) { error in
                isUploading = false
                if let error = error {
                    errorMessage = "Failed to save skill: \(error.localizedDescription)"
                    showErrorAlert = true
                } else {
                    showSuccessAlert = true
                    resetForm()
                }
            }
        }
    }


    func resetForm() {
        topic = ""
        description = ""
        videoURL = nil
        pdfURL = nil
        uploadProgress = 0.0
    }
}



// Preview
#Preview {
    SkillUpload()
}
