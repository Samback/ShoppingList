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

//        UINavigationBar.appearance().tintColor = ColorTheme.live().accent.uiColor
//        UINavigationBar.appearance().barTintColor = ColorTheme.live().accent.uiColor
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
