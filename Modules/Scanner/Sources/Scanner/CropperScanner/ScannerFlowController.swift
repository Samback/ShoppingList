//
//  File.swift
//
//
//  Created by Max Tymchii on 10.12.2023.
//

import Foundation
import AVFoundation
import UIKit
import SnapKit

protocol ScannerFlowControllerDelegate: AnyObject {
    func cancel()
    func textsRecognised(_ texts: [String])
}

public extension ScannerFlowController {
    enum FlowState {
        case capture
        case edit(image: UIImage)
        case recognise(image: UIImage)
    }
}

final public class ScannerFlowController: UIViewController {

    private let photoOutput = AVCapturePhotoOutput()

    private lazy var videoCaptureController: VideoCaptureController = {
        return VideoCaptureController.instantiate(with: self)
    }()

    private lazy var bottomViewController: BottomViewController = {
        return BottomViewController.instantiate(delegate: self)
    }()

    private var cropperViewController: CropperViewController?
    private var textListViewController: TextListViewController?

    private let topControllerContainer = UIView()
    private let bottomControllerContainer = UIView()

    private var flow: FlowState = .capture

    weak var delegate: ScannerFlowControllerDelegate?

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        activateFlow(.capture)
    }

    private func setupUI() {
        view.addSubview(topControllerContainer)
        view.addSubview(bottomControllerContainer)

        topControllerContainer.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        bottomControllerContainer.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.view.snp.bottom)
            make.height.equalTo(77)
            make.top.equalTo(topControllerContainer.snp.bottom)
        }

        attachChildViewController(childController: bottomViewController,
                                  containerView: bottomControllerContainer,
                                  sizing: .equalToSuperviewWithInsets(.zero))
    }

    private func activateFlow(_ flow: FlowState) {
        switch flow {
        case .capture:
            attachVideoCapture()
            bottomViewController.setupFlow(.capture)
        case let .edit(image):
            attachEditor(with: image)
            bottomViewController.setupFlow(.edit(image: image))
        case let .recognise(image: image):
            attachRecognise(image)
            bottomViewController.setupFlow(.recognise(image: image))
            return
        }
    }

    private func attachVideoCapture() {
        guard videoCaptureController.parent == nil else {
            return
        }

        attachChildViewController(childController: videoCaptureController,
                                  containerView: topControllerContainer,
                                  sizing: .equalToSuperviewWithInsets(.zero))
    }

    private func attachEditor(with image: UIImage) {
        let viewController = CropperViewController.makeViewController(with: image)

        cropperViewController = viewController
        attachChildViewController(childController: viewController,
                                  containerView: topControllerContainer,
                                  sizing: .equalToSuperviewWithInsets(.zero))
    }

    private func attachRecognise(_ image: UIImage) {
        let viewController = TextListViewController.makeViewController(with: image)

        textListViewController = viewController
        attachChildViewController(childController: viewController,
                                  containerView: topControllerContainer,
                                  sizing: .equalToSuperviewWithInsets(.zero))
    }

}

extension ScannerFlowController: VideoCaptureControllerDelegate {
    func dismiss() {
        delegate?.cancel()
    }

    func capturedImage(_ image: UIImage) {
        activateFlow(.edit(image: image))
    }

}

extension ScannerFlowController: BottomViewControllerDelegate {
    func didTapCancel() {
        delegate?.cancel()
    }

    func didTapRetake() {
        guard let cropperViewController = cropperViewController else {
            return
        }

        detachChildViewController(childController: cropperViewController)
        self.cropperViewController = nil
        activateFlow(.capture)
    }

    func didTapSave() {
        guard let image = cropperViewController?.croppedImage() else {
            return
        }

        activateFlow(.recognise(image: image))
    }

    func didTapSaveToList() {
        guard let texts = textListViewController?.listTexts() else {
            return
        }

        delegate?.textsRecognised(texts)
    }

}
