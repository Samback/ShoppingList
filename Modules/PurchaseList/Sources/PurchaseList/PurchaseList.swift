//
//  otesListView.swift
//  ShoppingList
//
//  Created by Max Tymchii on 22.09.2023.
//

import SwiftUI
import ComposableArchitecture
import Note
import Scanner

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
                VStack(spacing: 0) {
                    listView(with: viewStore)
                    inputView(with: viewStore)
                }
                .navigationTitle(viewStore.title)
                .toolbar {
                    toolbarView(with: viewStore)
                }
                .sheet(store: self.store.scope(state: \.$scanPurchaseList,
                                               action: {.scannerAction($0)}),
                       content: ScannerTCA.init)
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
    private func inputView(with viewStore: ViewStoreOf<PurchaseListFeature>) -> some View {
        MessageInputView(store:
                            self.store.scope(state: \.inputText, action: PurchaseListFeature.Action.inputTextAction))
        .background(.green)
        .clipShape(
            .rect(topLeadingRadius: 2.steps,
                  topTrailingRadius: 2.steps)
        )
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
