//
//  File.swift
//  
//
//  Created by Max Tymchii on 30.10.2023.
//

import Foundation
import SwiftUI

public struct NavigationTextModifier: ViewModifier {
    public let color: Color
    public let font: Font
    public func body(content: Content) -> some View {
        content
            .foregroundColor(color)
            .font(font)
    }
}

public extension View {
    func navigationActionButtonTitleModifier() -> some View {
        modifier(NavigationTextModifier(color: ColorTheme.live().accent,
                                        font: .system(size: 17, weight: .medium)))
    }

    func navigationTitleModifier() -> some View {
        modifier(NavigationTextModifier(color: ColorTheme.live().primary,
                                        font: .system(size: 18, weight: .bold)))
    }
}
