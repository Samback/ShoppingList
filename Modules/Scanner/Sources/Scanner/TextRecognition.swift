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
        return await withTaskGroup(of: [String].self) { group -> [String] in
            for image in scannedImages {
                group.addTask {
                        let text = try? await recognizeText(in: image)
                        return text ?? []
                }
            }

            var results = [String]()

            for await result in group {
                results.append(contentsOf: result)
            }

            return results
        }
    }

    @Sendable func recognizeText(in image: UIImage) async throws -> [String] {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                guard let cgImage = image.cgImage else {
                    continuation.resume(throwing: TextRecognitionError.noImage)
                    return
                }

                let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                try requestHandler.perform([getTextRecognitionRequest(with: continuation)])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private func getTextRecognitionRequest(with continuation: CheckedContinuation<[String], Error>) -> VNRecognizeTextRequest {
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }

            var texts = [String]()
            observations.forEach { observation in
                guard let recognizedText = observation.topCandidates(1).first else { return }
                print("TEXT: \(recognizedText.string)")
                texts.append(recognizedText.string)
            }

            continuation.resume(returning: texts)
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        return request
    }
}
