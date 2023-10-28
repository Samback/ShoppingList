//
//  File.swift
//  
//
//  Created by Max Tymchii on 28.10.2023.
//

import Foundation
import ComposableArchitecture

public struct UserDefaultsManager {
    public var listStateExpanded: @Sendable () -> Bool
    public var setListStateExpanded: @Sendable (Bool) -> Void
}

extension UserDefaultsManager: DependencyKey {

    private static let userDefaults = UserDefaults.standard

    public static var liveValue: Self {
        return UserDefaultsManager(listStateExpanded: { loadListStateExpanded() },
                                   setListStateExpanded: { saveListStateExpanded($0) }
        )
    }

    private static func loadListStateExpanded() -> Bool {
        userDefaults.bool(forKey: "listStateExpanded")
    }

    private static func saveListStateExpanded(_ value: Bool) {
        userDefaults.set(value, forKey: "listStateExpanded")
    }

}

public extension DependencyValues {
  var userDefaultsManager: UserDefaultsManager {
    get { self[UserDefaultsManager.self] }
    set { self[UserDefaultsManager.self] = newValue }
  }
}
