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

public struct ListManagerFeature: Reducer {
    @Dependency(\.uuid) var uuid
    @Dependency(\.dataManager) var dataManager

    public init() {}

    public struct State: Equatable {
        @PresentationState public var activePurchaseList: PurchaseListFeature.State?

        var purchaseListCollection: IdentifiedArrayOf<PurchaseListFeature.State> = []

        public init(purchaseListCollection: IdentifiedArrayOf<PurchaseListFeature.State>) {
            self.purchaseListCollection = purchaseListCollection
        }
    }

    public enum Action {
        case initialLoad
        case activePurchaseList(PresentationAction <PurchaseListFeature.Action>)
        case listAction(id: UUID, action: PurchaseListFeature.Action)
        case addNewList
        case delete(IndexSet)
        case loadedListResult(TaskResult<[PurchaseModel]>)
        case openList(PurchaseListFeature.State)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .listAction:
                return .none
            case .addNewList:
                let newPurchase = PurchaseModel.newPurchase()
                let newList = PurchaseListFeature.State(id: newPurchase.id,
                                                        notes: IdentifiedArrayOf<NoteFeature.State>(uniqueElements: []),
                                                        title: newPurchase.title)
                state.purchaseListCollection.append(newList)
                return .run { send in
                    try await dataManager.createDocument(newPurchase)
                    await send(.openList(newList))
                }

            case let .delete(indexSet):
                guard let firstIndex = indexSet.first else {
                    return .none
                }
                let value = state.purchaseListCollection.elements[firstIndex]
                state.purchaseListCollection.remove(atOffsets: indexSet)
                return .run { _ in
                    try await dataManager.deleteDocument(value.id.uuidString)
                }
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
            case .activePurchaseList:
                return .none
            case let .openList(purchaseListState):
                state.activePurchaseList = purchaseListState
                return .none
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
}
