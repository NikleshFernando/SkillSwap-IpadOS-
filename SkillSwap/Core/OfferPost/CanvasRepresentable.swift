//
//  CanvasRepresentable.swift
//  SkillSwap
//
//  Created by Niklesh Fernando on 2025-06-28.
//

import SwiftUI
import PencilKit

struct CanvasRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
        canvasView.backgroundColor = .white
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) { }
}
