import SwiftUI
import VisionKit
import Combine

private struct ScannerViewActionKey: EnvironmentKey {
  static let defaultValue = PassthroughSubject<ScannerView.Action, Never>()
}

// 2. Extend the environment with our property
extension EnvironmentValues {
  var scannerViewAction: PassthroughSubject<ScannerView.Action, Never> {
    get { self[ScannerViewActionKey.self] }
    set { self[ScannerViewActionKey.self] = newValue }
  }
}

public struct ScannerView: UIViewControllerRepresentable {

    public enum Action {
        case cancel
        case result([UIImage])
        case error(Error)
    }

    @Environment(\.scannerViewAction) var actionPublisher: PassthroughSubject<ScannerView.Action, Never>

    public func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = VNDocumentCameraViewController()

        viewController.delegate = context.coordinator

        return viewController
    }

    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(scannerView: self)
    }

    public class Coordinator: NSObject {
        var scannerView: ScannerView

        init(scannerView: ScannerView) {
            self.scannerView = scannerView
        }
    }

}

extension ScannerView.Coordinator: VNDocumentCameraViewControllerDelegate {
    public func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                             didFinishWith scan: VNDocumentCameraScan) {

        scannerView
            .actionPublisher
            .send(
                .result(
                    (0..<scan.pageCount).compactMap(scan.imageOfPage)
                )
                )

    }

    public func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        print("documentCameraViewControllerDidCancel")
        scannerView
            .actionPublisher
            .send(
                .cancel)
    }

    public func documentCameraViewController(_ controller: VNDocumentCameraViewController, 
                                             didFailWithError error: Error) {
        print("didFailWithError")
        scannerView
            .actionPublisher
            .send(
                .error(error))
    }

}

#Preview {
    UIHostingController(rootView: ScannerView())
}
