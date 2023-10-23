//
//  File.swift
//  
//
//  Created by Max Tymchii on 17.10.2023.
//

import Foundation
import ComposableArchitecture

public struct DraftListFeature: Reducer {

    public init() {}

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case tapOnAddAtShoppingList
        case delegate(Delegate)
        public enum Delegate: Equatable {
            case addNewShoppingNotes([String])
            case cancel
        }
    }

    public var body: some ReducerOf<DraftListFeature> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding(\.$inputText):
                state.inputText = state.inputText
                return .none
            case .binding:
                return .none
            case .tapOnAddAtShoppingList:
                let lines = state
                    .inputText
                    .split(whereSeparator: \.isNewline)
                    .map(String.init)
                return .send(.delegate(.addNewShoppingNotes(lines)))
            case .delegate:
                return .none
            }
        }
    }

    public struct State: Equatable {
       @BindingState var inputText: String = ""

        public init(rawList: [String]) {
            self.inputText = rawList.joined(separator: "\n")
        }
    }

}
