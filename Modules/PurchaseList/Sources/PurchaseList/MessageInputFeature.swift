//
//  MessageInputFeature.swift
//  ShoppingNotes
//
//  Created by Max Tymchii on 15.08.2023.
//

import Foundation
import ComposableArchitecture
import SwiftUI

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

        public enum Flow: Equatable, Sendable {
            case lists
            case purchaseList
        }

        public enum Mode: Equatable, Sendable {
            case create(Flow)
            case update(UUID, Flow)

            var actionButtonImage: Image {
                switch self {
                case .create:
                    return Image(systemName: "plus")
                        .resizable()
                case .update:
                    return Image(.arrowUp)
                        .resizable()
                }
            }

            var leadingOffset: CGFloat {
                switch self {
                case .create(.lists), .update(_, .lists):
                    return 16
                default:
                    return 64
                }
            }

            var placeholderText: String {
                switch self {
                case .create(.lists), .update(_, .lists):
                    return "Name your list"
                default:
                    return "Add new item(s)"
                }
            }
        }

        var isScannerEnabled: Bool {
            switch mode {
            case .create(.purchaseList), .update(_, .purchaseList):
                return true
            default:
                return false
            }
        }

        var isActionButtonEnabled: Bool {
            switch mode {
            case .create(.purchaseList), .update(_, .purchaseList):
                return !inputText.isEmpty
            default:
                return true
            }
        }

        public init(inputText: String = "", mode: Mode = .create(.lists)) {
            self.inputText = inputText
            self.mode = mode
        }
    }

}
