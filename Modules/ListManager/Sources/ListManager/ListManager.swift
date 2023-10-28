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
                    inputView(with: viewStore)
                }
                .navigationTitle("My list")
                .navigationDestination(store: self.store.scope(state: \.$activePurchaseList,
                                                               action: { .activePurchaseList($0) }),
                                       destination: PurchaseList.init)
            })
        }
    }

    private func toolBarView(with viewStore: ViewStoreOf<ListManagerFeature>) -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
                //                viewStore.send(.addNewList)
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
                                             .contextMenu {
                                                 contextMenu(with: viewStore, state: state)
                                             }

                                     }
                                 }
                                 .onDelete(perform: { indexSet in
                                     viewStore.send(.listInteractionAction(.delete(indexSet)))
                                 })
                                 .onMove(perform: { indices, newOffset in
                                     viewStore.send(.listInteractionAction(.move(indices, newOffset)))
                                 })

                                 .listStyle(.plain)
        }
        .scrollDismissesKeyboard(.immediately)
    }

    @ViewBuilder
    private func inputView(with viewStore: ViewStoreOf<ListManagerFeature>) -> some View {
        MessageInputView(store:
                            self.store.scope(state: \.inputField, action: ListManagerFeature.Action.inputFieldAction))
        .background(.green)
        .clipShape(
            .rect(topLeadingRadius: 2.steps,
                  topTrailingRadius: 2.steps)
        )
    }

    @ViewBuilder
    private func contextMenu(with viewStore: ViewStoreOf<ListManagerFeature>, state: PurchaseListFeature.State) -> some View {
        VStack {

            Button(action: {
                viewStore.send(.contextMenuAction(.rename(state.id)))
            }, label: {
                HStack {
                    Text("Rename")
                    Spacer()
                    Image(systemName: "character.cursor.ibeam")
                }
            })

            Button(action: {
                viewStore
                    .send(.contextMenuAction(.selectEmoji(state.id)))
            }, label: {
                HStack {
                    Text("Change image")
                    Spacer()
                    Image(systemName: "smiley")
                }
            })

            Button(action: {
                viewStore
                    .send(.contextMenuAction(.duplicate(state.id)))
            }, label: {
                HStack {
                    Text("Duplicate")
                    Spacer()
                    Image(systemName: "doc.on.doc")
                }
            })

            ShareLink(item: state.purchaseModel.shareVersion()) {
                HStack {
                    Text("Share")
                    Spacer()
                    Image(systemName: "square.and.arrow.up")
                }
            }

            Button(role: .destructive, action: {
                viewStore
                    .send(.contextMenuAction(.delete(state.id)))
            }, label: {
                HStack {
                    Text("Delete")
                    Spacer()
                    Image(systemName: "trash")
                }
            })
            Divider()

            Button(action: {
                viewStore
                    .send(.contextMenuAction(.mark(state.id)))
            }, label: {
                HStack {
                    Text(state.status.title)
                    Spacer()
                    Image(systemName: state.status.imageIcon)
                }
            })
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
