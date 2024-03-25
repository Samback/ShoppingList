//
//  File.swift
//  
//
//  Created by Max Tymchii on 28.10.2023.
//

import Foundation
import ComposableArchitecture
import UIKit

public struct UserDefaultsManager {
    public var listStateExpanded: @Sendable () -> Bool
    public var setListStateExpanded: @Sendable (Bool) -> Void
    public var userInterfaceStyle: @Sendable () -> UIUserInterfaceStyle
    public var setUserInterfaceStyle: @Sendable (UIUserInterfaceStyle) -> Void
}

extension UserDefaultsManager: DependencyKey {

    private static let userDefaults = UserDefaults.standard

    public static var liveValue: Self {
        return UserDefaultsManager(listStateExpanded: { loadListStateExpanded() },
                                   setListStateExpanded: { saveListStateExpanded($0)} ,
                                   userInterfaceStyle: { userInterfaceStyle() },
                                   setUserInterfaceStyle: { setUserInterfaceStyle($0) }
        )
    }

    private static func loadListStateExpanded() -> Bool {
        userDefaults.bool(forKey: "listStateExpanded")
    }

    private static func saveListStateExpanded(_ value: Bool) {
        userDefaults.set(value, forKey: "listStateExpanded")
    }
    
    private static func userInterfaceStyle() -> UIUserInterfaceStyle {
        let value = userDefaults.integer(forKey: "UIUserInterfaceStyle")
        return UIUserInterfaceStyle(rawValue: value) ?? .light
    }
    
    private static func setUserInterfaceStyle(_ value: UIUserInterfaceStyle) {
            userDefaults.set(value.rawValue, forKey: "UIUserInterfaceStyle")
    }
    
}

public extension DependencyValues {
  var userDefaultsManager: UserDefaultsManager {
    get { self[UserDefaultsManager.self] }
    set { self[UserDefaultsManager.self] = newValue }
  }
}
