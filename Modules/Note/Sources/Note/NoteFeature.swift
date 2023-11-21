//
//  NoteFeature.swift
//  ShoppingList
//
//  Created by Max Tymchii on 21.09.2023.
//

import Foundation
import ComposableArchitecture
import Models

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
        @BindingState public var title: String
        @BindingState public var status: Status

        var titlePrefix: String {
            return String(title.prefix(3))
        }

        var titleSuffix: String {
            return String(title.dropFirst(3))
        }

        public static let demo = State(id: UUID(),
                                title: "Milk",
                                status: .new)

        public init(id: UUID,
                    title: String,
                    status: Status) {
            self.id = id
            self.title = title
            self._status = BindingState(wrappedValue: status)
        }

        public static func convert(from model: NoteModel) -> Self {
            return .init(id: model.id,
                         title: model.title,
                         status: model.isCompleted ? .done : .new)
        }
    }

    public enum Action: BindableAction, Equatable, Sendable {
        case binding(BindingAction<State>)
    }

    public var body: some ReducerOf<Self> {
      BindingReducer()
    }
}
