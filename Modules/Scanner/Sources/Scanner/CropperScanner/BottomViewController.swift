//
//  File.swift
//
//
//  Created by Max Tymchii on 10.12.2023.
//

import Foundation
import UIKit
import SnapKit

protocol BottomViewControllerDelegate {
    func didTapCancel()
    func didTapRetake()
    func didTapSave()
    func didTapSaveToList()
}

final class BottomViewController: UIViewController {
    var delegate: BottomViewControllerDelegate?

    private let horizontalStack = UIStackView()

    fileprivate lazy var cancelButton: UIButton = {
        return makeButton(title: "Cancel",
                          alignment: .left,
                          action:
                            UIAction { [weak self] _ in
            self?.delegate?.didTapCancel()}
        )
    }()

    fileprivate lazy var retakeButton: UIButton = {
        return makeButton(title: "Retake",
                          alignment: .left,
                          action:
                            UIAction { [weak self] _ in
            self?.delegate?.didTapRetake()}
        )
    }()

    fileprivate lazy var saveButton: UIButton = {
        return makeButton(title: "Save",
                          alignment: .right,
                          action:
                            UIAction { [weak self] _ in
            self?.delegate?.didTapSave()}
        )
    }()

    fileprivate lazy var saveToListButton: UIButton = {
        return makeButton(title: "Save to list",
                          alignment: .right,
                          action:
                            UIAction { [weak self] _ in
            self?.delegate?.didTapSaveToList()}
        )
    }()

    private func makeButton(title: String, alignment: UIControl.ContentHorizontalAlignment, action: UIAction) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.contentHorizontalAlignment = alignment
        button.addAction(action, for: .touchUpInside)
        return button
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {

        horizontalStack.axis = .horizontal
        horizontalStack.distribution = .fillEqually

        view.addSubview(horizontalStack)

        horizontalStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(8)
        }
    }


    func setupFlow(_ flow: ScannerFlowController.FlowState) {

        horizontalStack.arrangedSubviews.forEach {
            horizontalStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        switch flow {
        case .capture:
            horizontalStack.addArrangedSubview(cancelButton)
            horizontalStack.addArrangedSubview(UIView.spacer())
        case .edit:
            horizontalStack.addArrangedSubview(cancelButton)
            horizontalStack.addArrangedSubview(retakeButton)
            horizontalStack.addArrangedSubview(saveButton)
        case .recognise:
            horizontalStack.addArrangedSubview(cancelButton)
            horizontalStack.addArrangedSubview(UIView.spacer())
            horizontalStack.addArrangedSubview(saveToListButton)
        }
    }

}


extension BottomViewController {
    static func instantiate(delegate: BottomViewControllerDelegate) -> BottomViewController {
        let viewController = BottomViewController(nibName: nil, bundle: nil)
        viewController.view.backgroundColor = .black
        viewController.delegate = delegate
        return viewController
    }

}
