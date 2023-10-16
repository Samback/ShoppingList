//
//  TextRecognition.swift/

import SwiftUI
import Vision

struct TextRecognition {

    enum TextRecognitionError: Error {
        case noImage
    }

    private let scannedImages: [UIImage]

    init(scannedImages: [UIImage]) {
        self.scannedImages = scannedImages
    }

    func recognizeText() async -> [String] {
        let texts = await withTaskGroup(of: String.self) { group -> [String] in
            for image in scannedImages {
                group.addTask {
                        let text = try? await recognizeText(in: image)
                        return text ?? ""
                }
            }

            var results = [String]()

            for await result in group {
                results.append(result)
            }

            return results
        }

        return texts
    }

    @Sendable func recognizeText(in image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else { throw TextRecognitionError.noImage }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        var text: String = ""
        try requestHandler.perform([getTextRecognitionRequest(&text)])
        return text
    }

    private func getTextRecognitionRequest(_ text: inout String) -> VNRecognizeTextRequest {
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }

            observations.forEach { observation in
                guard let recognizedText = observation.topCandidates(1).first else { return }
                print("TEXT: \(recognizedText.string)")
            }
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        return request
    }
}
