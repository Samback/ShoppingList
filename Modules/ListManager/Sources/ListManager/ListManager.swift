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
import Emojis
import SwiftUISplashScreen
import Inject
import Tips
import TipKit

public struct ListManager: View {

    @Bindable var store: StoreOf<ListManagerFeature>
    @ObserveInjection var inject

    public init(store: StoreOf<ListManagerFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
                ZStack {
                    listView()
                        .background(.clear)
                        .ignoresSafeArea(.keyboard)
                        .safeAreaPadding(.top, 8)
                        .safeAreaPadding(.bottom, 86)
                        .padding(.horizontal, 0)

                    VStack {
                        Spacer()

                        inputView()
                            .padding(.bottom, -34)
                            .ignoresSafeArea(.keyboard)
                    }
                    .background(.clear)
                }
                .navigationTitle("Pero lists")
                .background(ColorTheme.live().white)
                .onAppear {
                    
                    Appearance.apply()
                }
                .sheet(item: $store.scope(state: \.emojisSelector,
                                               action: \.emojisSelectorAction),
                       content: EmojisView.init)
                .confirmationDialog($store.scope(state: \.confirmationDialog,
                                                            action: \.confirmationDialog))
                .navigationDestination(item: $store.scope(state: \.activePurchaseList,
                                                               action: \.activePurchaseList),
                                       destination: PurchaseList.init)
        }
        .task {
            store.send(.initialLoad)
        }
        .splashView(timeout: 1) {
            VStack {
                SplashScreenView()
                
            }
        }
        .enableInjection()
    }


    @ViewBuilder
    private func listView() -> some View {
        List {
//            TipView(OrganiseListTip())
            ForEach(
                self
                    .store
                    .scope(state: \.purchaseListCollection,
                           action: \.listActions)) { localStore in
                               PurchaseListCell(purchaseModel: localStore.state.purchaseModel)
                                   .onTapGesture {
                                       store.send(.openList(id: localStore.state.id))
                                   }
                                   .swipeActions(edge: .trailing) {
                                       swipeButtons(state: localStore.state)
                                   }
                                   .contextMenu {
                                       contextMenu(state: localStore.state)
                                   }
                           }
                           .onMove(perform: { indices, newOffset in
                               store.send(.listInteractionAction(.move(indices, newOffset)))
                           })
                           .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                           .listRowSeparatorTint(ColorTheme.live().separator)
                           .listRowBackground(ColorTheme.live().white)
                           .listSectionSeparator(.hidden, edges: .top)
        }
        .overlay(content: {
            if store.purchaseListCollection.isEmpty {
                EmptyListView()
            }
        })
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.immediately)
    }

    @ViewBuilder
    private func swipeButtons(state: PurchaseListFeature.State) -> some View {
        HStack {
            Button(
                action: {
                    store
                        .send(
                            .contextMenuAction(.delete(state.id)))
                }, label: {
                    HStack {
                        Text("Delete")
                    }
                })
            .tint(ColorTheme.live().destructive)

            Button(action: {
                store.send(.showConfirmationDialog(state.id))
            }, label: {
                Text("Options")
            })
            .tint(ColorTheme.live().secondary)
        }
    }

    @ViewBuilder
    private func inputView() -> some View {
        MessageInputView(store:
                            self.store.scope(state: \.inputField, action: \.inputFieldAction))
    }

    @ViewBuilder
    private func contextMenu(state: PurchaseListFeature.State) -> some View {
        VStack {

            Button(action: {
                store.send(.contextMenuAction(.rename(state.id)))
            }, label: {
                HStack {
                    Text("Rename")
                    Spacer()
                    Image(systemName: "character.cursor.ibeam")
                }
            })

            Button(action: {
                store
                    .send(.contextMenuAction(.selectEmoji(state.id)))
            }, label: {
                HStack {
                    Text("Change image")
                    Spacer()
                    Image(systemName: "smiley")
                }
            })

            Button(action: {
                store
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
                store
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
                store
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
