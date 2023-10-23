//
//  File.swift
//  
//
//  Created by Max Tymchii on 16.10.2023.
//

import Foundation
import ComposableArchitecture
import UIKit

public struct TextRecognitionService {
    public var recognizeText: @Sendable ([UIImage]) async -> [String]
}

extension TextRecognitionService: DependencyKey {
    public static var liveValue: Self {
        return TextRecognitionService(recognizeText: { images in
                await TextRecognition(scannedImages: images)
                .recognizeText()
        })
    }

    public static var previewValue: Self {
        return TextRecognitionService(recognizeText: { _ in
                ["Some text that we simulated"]
        })
    }
}

public extension DependencyValues {
  var recognitionService: TextRecognitionService {
    get { self[TextRecognitionService.self] }
    set { self[TextRecognitionService.self] = newValue }
  }
}
