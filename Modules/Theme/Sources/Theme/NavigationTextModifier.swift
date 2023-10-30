//
//  File.swift
//  
//
//  Created by Max Tymchii on 30.10.2023.
//

import Foundation
import SwiftUI

public struct NavigationTextModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .foregroundColor(ColorTheme.live().accent)
            .font(.system(size: 17, weight: .medium))
    }
}

public extension View {
    func navigationTextModifier() -> some View {
        modifier(NavigationTextModifier())
    }
}
