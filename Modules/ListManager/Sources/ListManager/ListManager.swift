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
import Theme

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
                ZStack {
                    listView(with: viewStore)
                        .background(.clear)
                        .padding(.trailing, 16)
                        .padding(.bottom, 86)
                        .ignoresSafeArea(.keyboard)

                    VStack {
                        Spacer()

                        inputView(with: viewStore)
                            .padding(.bottom, -34)
                            .ignoresSafeArea(.keyboard)
                    }
                    .background(.clear)
                }
                .navigationTitle("My list")
                .background(ColorTheme.live().white)
                .onAppear {
                    Appearance.apply()
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
                                         PurchaseListCell(purchaseModel: state.purchaseModel)
                                             .onTapGesture {
                                                 viewStore.send(.openList(state))
                                             }
                                             .swipeActions {
                                                     HStack {
                                                         Button(
                                                          action: {
                                                              viewStore
                                                                  .send(
                                                                    .contextMenuAction(.delete(state.id)))
                                                          }, label: {
                                                              HStack {
                                                                  Text("Delete")
                                                              }
                                                          })
                                                         .tint(ColorTheme.live().destructive)

                                                         Button(action: {
                                                             /* viewStore.send(.showActionSheet(localState.id))
                                                              */
                                                         }, label: {
                                                             Text("Options")
                                                         })
                                                         .tint(ColorTheme.live().secondary)
                                                     }
                                             }
                                             .contextMenu {
                                                 contextMenu(with: viewStore, state: state)
                                             }
                                     }
                                 }
                                 .onMove(perform: { indices, newOffset in
                                     viewStore.send(.listInteractionAction(.move(indices, newOffset)))
                                 })
                                 .listRowSeparator(.hidden)
                                 .listRowInsets(.init(top: 8, leading: 16, bottom: 1, trailing: 1))
                                 .listSectionSeparator(.hidden, edges: .top)
                                 .background(ColorTheme.live().white)
        }
        .listStyle(.plain)
        .scrollDismissesKeyboard(.immediately)
    }

    @ViewBuilder
    private func inputView(with viewStore: ViewStoreOf<ListManagerFeature>) -> some View {
        MessageInputView(store:
                            self.store.scope(state: \.inputField, action: ListManagerFeature.Action.inputFieldAction))
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

            Button(action: {
                viewStore
                    .send(.contextMenuAction(.mark(state.id)))
            }, label: {
                HStack {
                    Text(state.purchaseModel.status.titleInverted)
                    Spacer()
                    Image(systemName: state.purchaseModel.status.imageIconInverted)
                }
            })

            Divider()

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
                                                                $0.dataManager = DataManager.liveValue
                                                            }
                                                           )
        )
}
