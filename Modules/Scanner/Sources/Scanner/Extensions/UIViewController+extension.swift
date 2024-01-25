//
//  UIViewController+extension.swift
//
//

import Foundation
import UIKit
import SnapKit

public extension UIViewController {

    enum SizingOption {
        case equalToSuperviewWithInsets(UIEdgeInsets)
        case centeredWithFixedSize(CGSize)
        case customSizing((UIViewController) -> Void)
    }

    func attachChildViewController(childController: UIViewController,
                                          containerView: UIView,
                                          sizing: SizingOption) {
        addChild(childController)

        containerView.addSubview(childController.view)
        
        switch sizing {
        case .equalToSuperviewWithInsets(let inset):
            childController
                .view
                .snp
                .makeConstraints { make in
                    make.edges.equalToSuperview().inset(inset)
            }

        case .centeredWithFixedSize(let size):
            childController
                .view
                .snp
                .makeConstraints { make in
                    make.centerX.centerY.equalToSuperview()
                    make.width.equalTo(size.width)
                    make.height.equalTo(size.height)
                }

        case .customSizing(let sizingClosure):
            sizingClosure(childController)
        }

        childController.didMove(toParent: self)
    }

    func detachChildViewController(childController: UIViewController) {
        if children.contains(childController) {
            childController.willMove(toParent: nil)
            childController.view.removeFromSuperview()
            childController.removeFromParent()
        }
    }

    func setRootViewController(_ viewController: UIViewController) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.33) {
            self.navigationController?.setViewControllers([viewController], animated: true)
        }
    }

}
