//
//  File.swift
//
//
//  Created by Max Tymchii on 10.12.2023.
//

import Foundation
import UIKit
import SwiftUI

public struct ScannerFlowView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var texts: [String]

    public func updateUIViewController(_ uiViewController: ScannerFlowController, context: Context) {
    }

    public typealias UIViewControllerType = ScannerFlowController

    public func makeUIViewController(context: Context) -> ScannerFlowController {
        let picker = ScannerFlowController()
        picker.delegate = context.coordinator
        return picker
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, ScannerFlowControllerDelegate {
        var parent: ScannerFlowView

        init(_ parent: ScannerFlowView) {
            self.parent = parent
        }

        public func cancel() {
            parent.isPresented = false
        }

        public func textsRecognised(_ texts: [String]) {
            parent.texts = texts
            print("Parent texts \(parent.texts)")
        }
    }

}
