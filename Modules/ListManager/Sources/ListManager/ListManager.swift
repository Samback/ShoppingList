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
import SwipeActions

public struct ListManager: View {

    @State var bindingState: SwipeState = .untouched

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
                        .padding(.bottom, 86)
                        .ignoresSafeArea(.keyboard)
                        .safeAreaPadding(.top, 8)
                        .padding(.horizontal, 0)

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
                .sheet(store: self.store.scope(state: \.$emojisSelector,
                                               action: { .emojisSelectorAction($0) }),
                       content: EmojisView.init)
                .confirmationDialog(store: self.store.scope(state: \.$confirmationDialog,
                                                            action: { .confirmationDialog($0) }))
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
                self
                    .store
                    .scope(state: \.purchaseListCollection,
                           action: ListManagerFeature.Action.listAction(id: action:))) { store in
                               store.withState { state in
                                   PurchaseListCell(purchaseModel: state.purchaseModel)
                                       .frame(width: UIScreen.main.bounds.size.width - 32, height: 80)
                                       .onTapGesture {
                                           viewStore.send(.openList(state))
                                       }
                                       .addSwipeAction(menu: .swiped,
                                                       edge: .trailing,
                                                       state: $bindingState) {
                                           swipeButtons(with: viewStore)
                                       }
                                                       .contextMenu {
                                                           contextMenu(with: viewStore, state: state)
                                                       }
                               }
                           }
                           .onMove(perform: { indices, newOffset in
                               viewStore.send(.listInteractionAction(.move(indices, newOffset)))
                           })
                           .listRowBackground(ColorTheme.live().white)
                           .listRowSeparator(.hidden)
                           .listRowInsets(.init(top: 4, leading: 16, bottom: 4, trailing: 16))
                           .background(ColorTheme.live().white)
        }

        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.immediately)
    }

    @ViewBuilder
    private func swipeButtons(with viewStore: ViewStoreOf<ListManagerFeature>) -> some View {
        HStack(spacing: 0) {
            Button(action: {

            }, label: {
                Text("Options")
            })
            .frame(width: 100, height: 80, alignment: .center)
            .contentShape(Rectangle())
            .background(ColorTheme.live().secondary)

            Button(action: {

            }, label: {
                HStack {
                    Text("Delete")
                }
            })
            .frame(width: 100, height: 80, alignment: .center)
            .contentShape(Rectangle())
            .background(ColorTheme.live().destructive)
            .clipShape(
                .rect(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 12,
                    topTrailingRadius: 12
                )
            )

            Rectangle().fill(.white).frame(width: 4.0, height: 80)
        }
        .background(HStack {
            Spacer()
            Rectangle().fill(ColorTheme.live().secondary).frame(width: 160.0, height: 80)

            Spacer(minLength: 180)
        }
            .background(.clear))
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
