//
//  File.swift
//
//
//  Created by Max Tymchii on 29.10.2023.
//

import Foundation
import SwiftUI
import UIKit
import Combine

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

public extension UIWindow {
    
    func reload() {
        subviews.forEach { view in
            view.removeFromSuperview()
            addSubview(view)
        }
    }
}

public class Appearance {
    
    
    public static  func apply() {
        apply(userInterfaceStyle: .light, blureStyle: .light)
        apply(userInterfaceStyle: .dark, blureStyle: .dark)
    }
    
    private static func apply(userInterfaceStyle: UIUserInterfaceStyle, blureStyle: UIBlurEffect.Style) {
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
//        appearance.backgroundEffect = UIBlurEffect(style: .prominent)
        let currentTrait = UITraitCollection(userInterfaceStyle: userInterfaceStyle)

        
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
        
        
        UINavigationBar.appearance(for: currentTrait).standardAppearance = appearance
        UINavigationBar.appearance(for: currentTrait).scrollEdgeAppearance = appearance
        UINavigationBar.appearance(for: currentTrait).compactAppearance = appearance
        
    }
}
