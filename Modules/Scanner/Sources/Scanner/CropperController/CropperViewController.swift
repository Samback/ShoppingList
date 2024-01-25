//
//  File.swift
//  
//
//  Created by Max Tymchii on 11.12.2023.
//

import Foundation
import UIKit


final class CropperViewController: UIViewController {

    static func makeViewController(with image: UIImage) -> CropperViewController {
        let viewController = CropperViewController(nibName: nil, bundle: nil)
        viewController.cropperImage.attachImage(image)
        return viewController
    }

    private var cropperImage = CropperEditorView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        view.addSubview(cropperImage)

        cropperImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        cropperImage.redrawFrame()
    }

    func croppedImage() -> UIImage? {
        return cropperImage.croppedImage()
    }

}
