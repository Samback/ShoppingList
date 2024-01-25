//
//  File.swift
//
//
//  Created by Max Tymchii on 05.12.2023.
//

import Foundation
import UIKit
import Combine
import ZImageCropper
import SnapKit

final class CropperEditorView: UIView {

    private let workingArea = UIView()
    private var cornerViews = [CornerView]()

    private var shapeLayer = CAShapeLayer()
    private let imageView = UIImageView()

    private let shadowArea = UIView()
    private let shadowLayer = CAShapeLayer()

    private var cancellable = Set<AnyCancellable>()

    public func attachImage(_ image: UIImage) {
        imageView.image = image
    }

    public func croppedImage() -> UIImage {
        return ZImageCropper
            .cropImage(ofImageView: imageView,
                       withinPoints: updateCorners()) ?? imageView.image ?? UIImage()
    }

    convenience init(image: UIImage) {
        self.init(frame: .zero)
        self.imageView.image = image
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        addImageView()
        addShadowArea()
        addShadowLayer()
        addWorkingArea()
        addShapeLayer()
        addCorners()
    }

    private func addImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func addShadowArea() {
        shadowArea.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        shadowArea.translatesAutoresizingMaskIntoConstraints = false
        addSubview(shadowArea)

        shadowArea.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func addShadowLayer() {
        shadowLayer.fillRule = .evenOdd
        shadowLayer.position = layer.position
        shadowArea.layer.mask = shadowLayer
        shadowArea.isUserInteractionEnabled = true
    }

    private func addWorkingArea() {
        workingArea.backgroundColor = .clear
        workingArea.translatesAutoresizingMaskIntoConstraints = false
        addSubview(workingArea)

        workingArea.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func addShapeLayer() {
        workingArea.layer.addSublayer(shapeLayer)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.position = layer.position
        workingArea.isUserInteractionEnabled = true
    }

    public func addCorners() {
        let offset: CGFloat = 5
        let size = CGSize(width: 50, height: 50)

        let topLeft = CornerView()
        let bottomLeft = CornerView()
        let topRight = CornerView()
        let bottomRight = CornerView()

        cornerViews = [topLeft, bottomLeft, topRight, bottomRight]

        cornerViews.forEach {
            $0.frame = .zero
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .clear
            $0.isUserInteractionEnabled = true
            workingArea.addSubview($0)

            $0.snp.makeConstraints { make in
                make.width.height.equalTo(size.width)
            }

            $0.coordinateObserver.sink { [weak self] _ in
                self?.redrawFrame()
            }.store(in: &cancellable)
        }

        topLeft.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(offset)
        }

        bottomRight.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview().offset(-offset)
        }

        bottomLeft.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-offset)
            make.leading.equalToSuperview().offset(offset)
        }

        topRight.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(offset)
            make.trailing.equalToSuperview().offset(-offset)
        }

        layoutIfNeeded()

    }


    func redrawFrame() {
        let points = updateCorners()
        drawFrame(orderedPoints: points)
    }

    private func updateCorners() -> [CGPoint] {
        cornerViews
            .map { $0.frame.center }
            .getHull()
    }

    private func drawFrame(orderedPoints: [CGPoint]) {

        let path = UIBezierPath()
        guard let first = orderedPoints.first else {
            return
        }

        path.move(to: first)
        var pathPoints = orderedPoints
        pathPoints.append(first)

        pathPoints.forEach {
            path.addLine(to: $0)
        }

        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = 2
        shapeLayer.strokeColor = UIColor.white.cgColor

        let shadowPath = UIBezierPath(rect: shadowArea.bounds)
        shadowPath.append(path)
        shadowLayer.path = shadowPath.cgPath
    }
}



#Preview {
    let corner = CropperEditorView(frame: CGRect(x: 0,
                                                 y: 0,
                                                 width: 400,
                                                 height: 800))

    corner.backgroundColor = .green

    let view = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 800))
    view.addSubview(corner)

    return view
}

