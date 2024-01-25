//
//  File.swift
//  
//
//  Created by Max Tymchii on 10.12.2023.
//

import UIKit

extension UIView {

    static func spacer(size: CGFloat = .greatestFiniteMagnitude,
                       for layout: NSLayoutConstraint.Axis = .horizontal) -> UIView {
        let spacer = UIView()
        // maximum width constraint
        let spacerWidthConstraint = spacer.widthAnchor.constraint(equalToConstant: size) // or some very high constant
        spacerWidthConstraint.priority = .defaultLow // ensures it will not "overgrow"
        spacerWidthConstraint.isActive = true
        return spacer
    }

}
