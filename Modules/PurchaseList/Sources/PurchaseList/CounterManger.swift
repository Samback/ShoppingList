//
//  File.swift
//  
//
//  Created by Max Tymchii on 13.11.2023.
//

import Foundation
import ComposableArchitecture
import Theme

public struct CounterManger {
    public var updateCounter: @Sendable (CounterView.Counter) -> Void
}

extension CounterManger: DependencyKey {

    public static var liveValue: Self {
        return CounterManger(updateCounter: { @MainActor counter in
            CounterView.publisher.send(counter)
        })
    }
}

public extension DependencyValues {
  var counterManager: CounterManger {
    get { self[CounterManger.self] }
    set { self[CounterManger.self] = newValue }
  }
}
