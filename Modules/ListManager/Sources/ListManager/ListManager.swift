//
//  ListManagerView.swift
//  ShoppingList
//
//  Created by Max Tymchii on 25.09.2023.
//

import SwiftUI
import ComposableArchitecture
import PurchaseList
import Utils

public struct ListManager: View {
    let store: StoreOf<ListManagerFeature>

    public init(store: StoreOf<ListManagerFeature>) {
        self.store = store
        store.send(.initialLoad)
    }

    public var body: some View {
        NavigationStack {
            WithViewStore(store,
                          observe: { $0 },
                          content: { viewStore in
                VStack {
                    listView(with: viewStore)
                }
                    .navigationTitle("My list")
                    .toolbar {
                        toolBarView(with: viewStore)
                    }
                    .navigationDestination(store: self.store.scope(state: \.$activePurchaseList,
                                                                   action: { .activePurchaseList($0) }),
                                           destination: PurchaseList.init)
            })
        }
    }


    private func toolBarView(with viewStore: ViewStoreOf<ListManagerFeature>) -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
                viewStore.send(.addNewList)
            }, label: {
                Image(systemName: "plus")
            })
        }
    }

    @ViewBuilder
    private func listView(with viewStore: ViewStoreOf<ListManagerFeature>) -> some View {
        List {
            ForEachStore(
                self.store.scope(state: \.purchaseListCollection,
                                 action: ListManagerFeature.Action.listAction(id: action:))) { store in
                                     store.withState { state in
                                         PurchaseListCell(title: state.title)
                                             .onTapGesture {
                                                 viewStore.send(.openList(state))
                                             }
                                     }
                                 }
                                 .onDelete(perform: { indexSet in
                                     viewStore.send(.delete(indexSet))
                                 })
                                 .listStyle(.plain)
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
                         $0.dataManager = DataManager.fileSystem
                     }
                    )
    )
}
