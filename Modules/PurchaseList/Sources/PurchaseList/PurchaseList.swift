//
//  otesListView.swift
//  ShoppingList
//
//  Created by Max Tymchii on 22.09.2023.
//

import SwiftUI
import ComposableArchitecture
import Note

public struct PurchaseList: View {
    let store: StoreOf<PurchaseListFeature>

    public init(store: StoreOf<PurchaseListFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store,
                      observe: { $0 },
                      content: { viewStore in
            NavigationStack {
                listView(with: viewStore)
                .navigationTitle(viewStore.title)
                .toolbar {
                    toolbarView(with: viewStore)
                }
            }
        })
    }

    private func toolbarView(with viewStore: ViewStoreOf<PurchaseListFeature>) -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: { viewStore.send(.uncheckAll) },
                   label: {
                    Text("🧽")
                   })
        }
    }

    @ViewBuilder
    private func listView(with viewStore: ViewStoreOf<PurchaseListFeature>) -> some View {
        List {
            ForEachStore(
                self
                    .store
                    .scope(state: \.notes,
                           action: PurchaseListFeature.Action.notesAction(id:action:))) {
                               NoteView(store: $0)
                           }
                           .onDelete { viewStore.send(.delete($0))}
                           .onMove { viewStore.send(.move($0, $1))}
        }
    }

}

#Preview {
    PurchaseList(
        store: Store(initialState: PurchaseListFeature.demo,
                     reducer: { PurchaseListFeature() }
                         )
    )
}
