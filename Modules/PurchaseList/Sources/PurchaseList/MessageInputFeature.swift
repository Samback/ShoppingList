//
//  MessageInputFeature.swift
//  ShoppingNotes
//
//  Created by Max Tymchii on 15.08.2023.
//

import Foundation
import ComposableArchitecture

struct MessageInputFeature: Reducer {

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .tapOnActionButton(let text):
                print(text)
                return .none
            case .textChanged(let text):
                state.inputText = text
                return .none
            case .clearInput:
                state.inputText = ""
                return .none
            }
        }
    }

    struct State: Equatable {
      @BindingState var inputText = ""
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case tapOnActionButton(String)
        case textChanged(String)
        case clearInput
    }
}
