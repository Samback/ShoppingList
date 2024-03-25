//
//  File.swift
//  
//
//  Created by Max Tymchii on 25.02.2024.
//

import Foundation
import UIKit
import UIKit
import Combine



public class ColorManager: ObservableObject {
    public static let shared = ColorManager()

    // This property will store the current color scheme
    @Published public var currentColorScheme: UIUserInterfaceStyle = .light

    public var cancellables: Set<AnyCancellable> = []

    init() {
        // Subscribe to trait collection changes using Combine
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.updateColorScheme()
            }
            .store(in: &cancellables)

        // Initial setup
        updateColorScheme()
    }

    private func updateColorScheme() {
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {

            let newColorScheme = windowScene.windows.first?.traitCollection.userInterfaceStyle ?? .light

            if newColorScheme != currentColorScheme {
                currentColorScheme = newColorScheme
            }
        }
    }
    
    public var schemeChanged: AsyncStream<UIUserInterfaceStyle> {
        AsyncStream { continuation in
            ColorManager.shared.$currentColorScheme.sink { value in
                continuation.yield(value)
            }.store(in: &ColorManager.shared.cancellables)
        }
    }
}
