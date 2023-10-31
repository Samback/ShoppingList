//
//  File.swift
//  
//
//  Created by Max Tymchii on 29.10.2023.
//

import Foundation
import SwiftUI

public struct Appearance {
    public static func apply() {
        let appearance = UINavigationBarAppearance()

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

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
