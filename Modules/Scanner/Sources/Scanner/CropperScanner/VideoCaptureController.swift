//
//  File.swift
//
//
//  Created by Max Tymchii on 10.12.2023.
//

import Foundation
import UIKit
import AVFoundation
import SnapKit

protocol VideoCaptureControllerDelegate {
    func dismiss()
    func capturedImage(_ image: UIImage)
}

class VideoCaptureController: UIViewController {

    enum TorchState {
        case enabled
        case disabled

        mutating func toggle() {
            switch self {
            case .enabled:
                self = .disabled
            case .disabled:
                self = .enabled
            }
        }

        var flash: AVCaptureDevice.FlashMode {
            switch self {
            case .enabled:
                return .on
            case .disabled:
                return .off
            }
        }

        var image: UIImage? {
            switch self {
            case .enabled:
                return UIImage(named: "flashOn", in: Bundle.module, with: nil)
            case .disabled:
                return UIImage(named: "flashOff", in: Bundle.module, with: nil)
            }

        }
    }

    var delegate: VideoCaptureControllerDelegate?

    private var torchState: TorchState = .disabled
    private let photoOutput = AVCapturePhotoOutput()
    private let torchButton = UIButton()

    static func instantiate(with delegate: VideoCaptureControllerDelegate?) -> VideoCaptureController {
        let viewController = VideoCaptureController(nibName: nil, bundle: nil)
        viewController.view.backgroundColor = .white
        viewController.delegate = delegate
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        openCamera()

    }

    private func setupUI() {
        attachTorch()
        attachTakePhoto()
    }

    private func attachTorch() {
        view.addSubview(torchButton)
        torchButton.setImage(torchState.image, for: .normal)

        torchButton.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(16)
        }

        torchButton
            .addAction(UIAction(handler: {[weak self] _ in
                guard let self = self else { return }

                self.torchState.toggle()
                torchButton.setImage(self.torchState.image, for: .normal)
            }), for: .touchUpInside)
    }


    private func attachTakePhoto() {
        let takeAPhotoButton = UIButton()

        view.addSubview(takeAPhotoButton)

        takeAPhotoButton.snp.makeConstraints { make in
            make.width.height.equalTo(65)
            make.bottom.equalToSuperview().offset(-27)
            make.centerX.equalToSuperview()
        }

        let image = UIImage(named: "takeAPhoto", in: Bundle.module, with: nil)
        takeAPhotoButton.setImage(image, for: .normal)

        takeAPhotoButton
            .addAction(UIAction(handler: { [weak self] _ in
                self?.takePhoto()
            }), for: .touchUpInside)
    }

    private func takePhoto() {
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = torchState.flash

        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            photoOutput.capturePhoto(with: photoSettings,
                                     delegate: self)
        }
    }

    private func openCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // the user has already authorized to access the camera.
            self.setupCaptureSession()

        case .notDetermined: // the user has not yet asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted { // if user has granted to access the camera.
                    print("the user has granted to access the camera")
                    DispatchQueue.main.async {
                        self.setupCaptureSession()
                    }
                } else {
                    print("the user has not granted to access the camera")
                    self.delegate?.dismiss()
                }
            }

        case .denied:
            print("the user has denied previously to access the camera.")
            self.delegate?.dismiss()

        case .restricted:
            print("the user can't give camera access due to some restriction.")
            self.delegate?.dismiss()

        default:
            print("something has wrong due to we can't access the camera.")
            self.delegate?.dismiss()
        }
    }

    private func setupCaptureSession() {
        let captureSession = AVCaptureSession()

        if let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) {
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
            } catch let error {
                print("Failed to set input device with error: \(error)")
            }

            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }

            let cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            cameraLayer.frame = self.view.frame
            cameraLayer.videoGravity = .resizeAspectFill
            self.view.layer.addSublayer(cameraLayer)

            captureSession.startRunning()
            DispatchQueue.global(qos: .background).async {
                captureSession.startRunning()
            }
            self.setupUI()
        }
    }
}




extension VideoCaptureController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let previewImage = UIImage(data: imageData) else {
            return
        }

        delegate?.capturedImage(previewImage)
    }
}
