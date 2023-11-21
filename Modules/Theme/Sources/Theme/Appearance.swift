//
//  File.swift
//  
//
//  Created by Max Tymchii on 29.10.2023.
//

import Foundation
import SwiftUI
import UIKit

extension UIColor {
    func as1ptImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        let ctx = UIGraphicsGetCurrentContext()!
        self.setFill()
        ctx.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}

public struct Appearance {
    public static func apply() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .light)

        appearance.largeTitleTextAttributes = [
            .foregroundColor: ColorTheme.live().primary.uiColor
        ]

        appearance.titleTextAttributes = [
            .foregroundColor: ColorTheme.live().primary.uiColor
        ]

        UIBarButtonItem.appearance().tintColor = ColorTheme.live().accent.uiColor
        appearance.backButtonAppearance.normal.titleTextAttributes =
        [.font: UIFont.systemFont(ofSize: 17, weight: .medium),
         .foregroundColor: ColorTheme.live().accent.uiColor
        ]

        appearance.shadowImage = UIColor.clear.as1ptImage()

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}
