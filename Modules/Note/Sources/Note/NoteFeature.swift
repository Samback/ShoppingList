//
//  NoteFeature.swift
//  ShoppingList
//
//  Created by Max Tymchii on 21.09.2023.
//

import Foundation
import ComposableArchitecture

public struct NoteFeature: Reducer {

    public init() {}

    public enum Status {
        case new
        case done

        mutating func toggle() {
            switch self {
            case .new:
                self = .done
            case .done:
                self = .new
            }
        }

    }

    public struct State: Equatable, Identifiable {
        public let id: UUID
        public let title: String
        public let subTitle: String?
        @BindingState public var status: Status

        public static let demo = State(id: .init(1),
                                title: "Milk",
                                subTitle: "Only fresh",
                                status: .new)

        public init(id: UUID,
                    title: String,
                    subTitle: String?,
                    status: Status) {
            self.id = id
            self.title = title
            self.subTitle = subTitle
            self._status = BindingState(wrappedValue: status)
        }
    
    }


    public enum Action: BindableAction, Equatable, Sendable {
        case binding(BindingAction<State>)
    }

    public var body: some ReducerOf<Self> {
      BindingReducer()
    }
}
