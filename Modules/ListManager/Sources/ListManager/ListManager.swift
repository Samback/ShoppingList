//
//  ListManagerView.swift
//  ShoppingList
//
//  Created by Max Tymchii on 25.09.2023.
//

import SwiftUI
import ComposableArchitecture
import PurchaseList
import Note
import Utils
import Models
import NonEmpty

struct ListManagerFeature: Reducer {
    @Dependency(\.uuid) var uuid
    @Dependency(\.dataManager.loadData) var loadData

    struct State: Equatable {

        var purchaseListCollection: IdentifiedArrayOf<PurchaseListFeature.State> = []

    }

    enum Action {
        case initialLoad
        case listAction(id: UUID, action: PurchaseListFeature.Action)
        case addNewList
        case delete(IndexSet)
        case loadedList([PurchaseModel])
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .listAction(id: let id, action: let action):
                return .none
            case .addNewList:
                return .none
            case .delete(_):
                return .none
            case .initialLoad:
                return .run { send in
                    let result = await loadData()
                    switch result {
                    case let .valid(list):
                        await send(.loadedList(list))
                    case let .invalid(errors):
                        print("Errors: \(errors.debugDescription)")
                    }
                }
            case let .loadedList(list):
                let value = list.compactMap { item in
                    let notes = item.notes.compactMap {
                        NoteFeature.State(id: $0.id,
                                          title: $0.title,
                                          subTitle: $0.subtitle,
                                          status: $0.isCompleted ? .done : .new)
                    }
                   return PurchaseListFeature.State(id: item.id,
                                                    notes: IdentifiedArray(uniqueElements: notes),
                                              title: item.title)
                }

                state.purchaseListCollection = IdentifiedArray(uniqueElements: value)

                return .none

            }
        }
        .forEach(\.purchaseListCollection,
                  action: /Action.listAction) {
            PurchaseListFeature()
        }
    }
}


struct ListManager: View {
    let store: StoreOf<ListManagerFeature>

    public init(store: StoreOf<ListManagerFeature>) {
        self.store = store
        store.send(.initialLoad)
    }

    var body: some View {
        NavigationStack {
            WithViewStore(store,
                          observe: { $0 }) { viewStore in
                List {
                    ForEachStore(
                        self.store.scope(state: \.purchaseListCollection,
                                         action: ListManagerFeature.Action.listAction(id: action:))) { store in
                                             store.withState { state in
                                                 NavigationLink {
                                                     PurchaseList(store: store)
                                                 } label: {
                                                     PurchaseListCell(title: state.title)
                                                 }
                                             }
                                         }
                }
            }
        }
    }
}

#Preview {
    ListManager(
        store: Store(initialState: ListManagerFeature.State(purchaseListCollection: []),
                     reducer: {
                         ListManagerFeature()
                     },
                     withDependencies: {
                         $0.dataManager.loadData = DataManager.previewValue.loadData
                     }
                    )
    )
}


