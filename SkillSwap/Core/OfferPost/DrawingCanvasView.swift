//
//  DrawingCanvasView.swift
//  SkillSwap
//
//  Created by Niklesh Fernando on 2025-06-28.
//

import SwiftUI
import PencilKit
import FirebaseStorage

struct DrawingCanvasView: View {
    @Binding var canvasView: PKCanvasView
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            CanvasRepresentable(canvasView: $canvasView)
                .background(Color.white)
                .cornerRadius(12)
                .padding()

            Button("Save Drawing") {
                saveDrawingToFirebase()
            }
            .padding()
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Sketch Something")
    }

    // MARK: - Save Drawing to Firebase
    func saveDrawingToFirebase() {
        let image = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale)

        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        let filename = UUID().uuidString + ".jpg"
        let storageRef = Storage.storage().reference().child("drawings/\(filename)")

        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("❌ Upload failed: \(error.localizedDescription)")
                return
            }

            storageRef.downloadURL { url, error in
                if let url = url {
                    print("✅ Drawing uploaded. URL: \(url.absoluteString)")
                    // You can now save this URL to Firestore, or attach it to a skill/offer
                }
            }
        }
    }
}



#Preview {
    StatefulPreviewWrapper(PKCanvasView()) { canvas in
        DrawingCanvasView(canvasView: canvas)
    }
}

