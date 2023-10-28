//
//  MessageInputFeature.swift
//  ShoppingNotes
//
//  Created by Max Tymchii on 15.08.2023.
//

import Foundation
import ComposableArchitecture

public struct MessageInputFeature: Reducer {

    public init() {}

    public enum Action: BindableAction, Equatable, Sendable {
        case binding(BindingAction<State>)
        case tapOnActionButton(String, State.Mode)
        case textChanged(String)
        case tapOnScannerButton
        case clearInput
        case activateTextField
    }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case let .tapOnActionButton(text, _):
                print(text)
                return .none
            case .textChanged(let text):
                state.inputText = text
                return .none
            case .clearInput:
                state.inputText = ""
                return .none
            case .tapOnScannerButton:
                return .none
            case .activateTextField:
                state.focusedField = .inputMessage
                return .none
            }
        }
    }

    public struct State: Equatable {
        @BindingState var inputText: String
        let mode: Mode

        @BindingState var focusedField: Field?

        public enum Field: String, Hashable {
          case inputMessage
        }

        public enum Mode: Equatable, Sendable {
            case create
            case update(UUID)
        }

        public init(inputText: String = "", mode: Mode = .create) {
            self.inputText = inputText
            self.mode = mode
        }
    }

}
