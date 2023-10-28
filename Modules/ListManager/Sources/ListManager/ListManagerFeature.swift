//
//  File.swift
//
//
//  Created by Max Tymchii on 12.10.2023.
//

import Foundation
import ComposableArchitecture
import PurchaseList
import Note
import Utils
import Models
import NonEmpty
import Analytics
import ComposableAnalytics

public struct ListManagerFeature: Reducer {
    @Dependency(\.uuid) var uuid
    @Dependency(\.dataManager) var dataManager

    public init() {}

    public struct State: Equatable {
        @PresentationState public var activePurchaseList: PurchaseListFeature.State?
        var inputField: MessageInputFeature.State

        var purchaseListCollection: IdentifiedArrayOf<PurchaseListFeature.State> = []

        public init(purchaseListCollection: IdentifiedArrayOf<PurchaseListFeature.State>,
                    inputField: MessageInputFeature.State = MessageInputFeature.State()) {
            self.purchaseListCollection = purchaseListCollection
            self.inputField = inputField
        }
    }

    public enum Action {
        case initialLoad
        case activePurchaseList(PresentationAction <PurchaseListFeature.Action>)
        case contextMenuAction(ContextMenuAction)
        case inputFieldAction(MessageInputFeature.Action)
        case listAction(id: UUID, action: PurchaseListFeature.Action)
        case listInteractionAction(ListInteractionAction)
        case addNewList(String?)
        case loadedListResult(TaskResult<[PurchaseModel]>)
        case openList(PurchaseListFeature.State)

        public enum ContextMenuAction: Equatable {
            case rename(UUID)
            case selectEmoji(UUID)
            case duplicate(UUID)
            case share(UUID)
            case delete(UUID)
            case mark(UUID)
        }

        public enum ListInteractionAction {
            case delete(IndexSet)
            case move(IndexSet, Int)

        }
    }

    public var body: some ReducerOf<Self> {

        Scope(state: \.inputField,
              action: /Action.inputFieldAction) {
            MessageInputFeature()
        }

        Reduce { state, action in
            switch action {
            case let .listAction(id, localActions):
                return listActions(with: &state,
                                   id: id, action: localActions)
            case let .addNewList(title):
                let newPurchase = PurchaseModel.newPurchase(title: title ?? "New item")
                let newList = PurchaseListFeature.State(id: newPurchase.id,
                                                        notes: IdentifiedArrayOf<NoteFeature.State>(uniqueElements: []),
                                                        title: newPurchase.title)
                state.purchaseListCollection.append(newList)
                return .run { send in
                    try await dataManager.createDocument(newPurchase)
                    await send(.openList(newList))
                }

            case let .contextMenuAction(localActions):
                return contextMenuActions(with: &state, action: localActions)

            case let .listInteractionAction(localActions):
                return listInteractionActions(with: &state, action: localActions)

            case .initialLoad:
                return .run { send in
                    await send(
                        .loadedListResult(
                            await TaskResult {
                                try await dataManager.loadData()
                            }
                        )
                    )
                }

            case let .loadedListResult(.success(list)):
                let items = list.compactMap(PurchaseListFeature.State.convert(from:))
                state.purchaseListCollection = IdentifiedArray(uniqueElements: items)
                return .none

            case let .loadedListResult(.failure(error)):
                print(error)
                return .none

            case let .openList(purchaseListState):
                state.activePurchaseList = purchaseListState
                if purchaseListState.notes.isEmpty {
                    return .send(.activePurchaseList(.presented(.inputTextAction(.activateTextField))))
                }
                return .none

            case let .activePurchaseList(localActions):
                return activePurchaseListActions(with: &state, action: localActions)

            case let .inputFieldAction(localActions):
                return inputFieldAction(with: &state, action: localActions)
            }
        }
        .ifLet(\.$activePurchaseList,
                action: /Action.activePurchaseList,
                destination: {
            PurchaseListFeature()
        })
        .forEach(\.purchaseListCollection,
                  action: /Action.listAction) {
            PurchaseListFeature()
        }
    }

    private func listInteractionActions(with state: inout State,
                                        action: Action.ListInteractionAction) -> Effect<Action> {
        switch action {
        case let .delete(indexSet):
            guard let firstIndex = indexSet.first else {
                return .none
            }
            let value = state.purchaseListCollection.elements[firstIndex]
            state.purchaseListCollection.remove(atOffsets: indexSet)
            return .run { _ in
                try await dataManager.deleteDocument(value.id.uuidString)
            }
        case let .move(indexSet, destination):
            state.purchaseListCollection.move(fromOffsets: indexSet, toOffset: destination)
            return .none
        }
    }

    private func activePurchaseListActions(with state: inout State,
                                           action: PresentationAction<PurchaseListFeature.Action>) -> Effect<Action> {
        switch action {
        case let .presented(.delegate(.update(activeState))):
            state.purchaseListCollection.updateOrAppend(activeState)
            return .none
        default:
            return .none
        }

    }

    private func contextMenuActions(with state: inout State,
                                    action: Action.ContextMenuAction) -> Effect<Action> {
        switch action {
        case let .rename(id):
            let title = state.purchaseListCollection[id: id]?.title
            state.inputField = MessageInputFeature.State(inputText: title ?? "", mode: .update(id))
            return .send(.inputFieldAction(.activateTextField))

        case let .delete(id):
            state.purchaseListCollection[id: id] = nil
            return .run { _ in
                try await dataManager.deleteDocument(id.uuidString)
            }

        case let .duplicate(id):
            guard let purchaseListState = state.purchaseListCollection[id: id] else {
                return .none
            }
            let duplicateState = PurchaseListFeature.State.convert(from: purchaseListState.purchaseModel.duplicate())
            state.purchaseListCollection.insert(duplicateState, at: 0)

            return .run { _ in
                try await dataManager.createDocument(duplicateState.purchaseModel)
            }

        case let .mark(id):
            guard let purchaseState = state.purchaseListCollection[id: id] else {
                return .none
            }

            return Effect<Action>
                .send(.listAction(id: id,
                                  action: purchaseState.status == .markAsDone ?
                    .checkAll : .uncheckAll))
        case let .share(id):
            return .none

        default:
            return .none
        }

//        case .selectEmoji(_):

    }

    private func listActions(with state: inout State, id: UUID,
                             action: PurchaseListFeature.Action) -> Effect<Action> {
        return .none
    }

    private func inputFieldAction(with state: inout State,
                                  action: MessageInputFeature.Action) -> Effect<Action> {
        switch action {
        case let .tapOnActionButton(title, mode):
            switch mode {
            case .create:
                state.inputField = MessageInputFeature.State(inputText: "", mode: .create)
                return .run { send in
                    await send(.addNewList(title))
                }
            case let .update(id):
                state.purchaseListCollection[id: id]?.title = title
                guard let model = state.purchaseListCollection[id: id] else {
                    return .none
                }

                state.inputField = MessageInputFeature.State(inputText: "", mode: .create)
                return .run { send in
                    try await dataManager.createDocument(model.purchaseModel)
                    await send(.inputFieldAction(.clearInput))

                }
            }
        case .tapOnScannerButton, .activateTextField,
                .binding, .clearInput, .textChanged:
            return .none
        }

    }
}
