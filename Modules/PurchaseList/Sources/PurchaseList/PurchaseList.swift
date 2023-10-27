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
import ComposableAnalytics
import Analytics

// https://www.hackingwithswift.com/quick-start/swiftui/how-to-add-custom-swipe-action-buttons-to-a-list-row
//https://www.swiftanytime.com/blog/contextmenu-in-swiftui

//https://kristaps.me/blog/swiftui-navigationview/

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
                            .background(.clear)
                        inputView(with: viewStore)
                    }
                    .background(.clear)
                }
                .scrollDismissesKeyboard(.immediately)
                .navigationTitle(viewStore.title + viewStore.title)

                .toolbar(content: {
                    toolbarView(with: viewStore)
                })
                .sheet(store: self.store.scope(state: \.$scanPurchaseList,
                                               action: {.scannerAction($0)}),
                       content: ScannerTCA.init)
                .sheet(store: self.store.scope(state: \.$draftList,
                                               action: {.draftListAction($0)}),
                       content: DraftList.init)
            })

    }

    private func toolbarView(with viewStore: ViewStoreOf<PurchaseListFeature>) -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Text("10/10")
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
                           action: PurchaseListFeature.Action.notesAction(id:action:))) { itemStore in
                               NoteView(store: itemStore)
                                   .swipeActions {
                                       itemStore.withState { localState in
                                           HStack {
                                               Button(action: {
                                                   print("Options")
                                               }, label: {
                                                   Text("Options")
                                               })
                                               .contextMenu {
                                                   Button(action: {
                                                       print("Options")
                                                   }, label: {
                                                       Text("Options")
                                                   })
                                               }
                                               Button(
                                                role: .destructive,
                                                action: {
                                                    viewStore.send(.deleteNote(localState.id))
                                                }, label: {
                                                    HStack {
                                                        Text("Delete")
                                                    }
                                                })
                                           }
                                       }
                                   }
                                   .contextMenu {
                                       itemStore.withState { state in
                                           contextMenuItems(with: viewStore, item: state)
                                       }
                                   }
                                   .frame(height: 30)
                           }
                           .onDelete { viewStore.send(.delete($0))}
                           .onMove { viewStore.send(.move($0, $1))}
        }
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
    }

    @ViewBuilder
    private func contextMenuItems(with viewStore: ViewStoreOf<PurchaseListFeature>,
                                  item state: NoteFeature.State) -> some View {
        Group {
            Button(action: {
                print("Tap on edit")
                viewStore.send(.edit(state.id))
            }, label: {
                HStack {
                    Text("Edit")
                }
            })
            Button(action: {
                print("Tap on duplicate")
                viewStore.send(.duplicate(state.id))
            }, label: {
                HStack {
                    Text("Duplicate")
                }
            })
            Button(
                role: .destructive,
                action: {
                    viewStore.send(.deleteNote(state.id))
                }, label: {
                    HStack {
                        Text("Delete")
                    }
                })
            Divider()
            Button(action: {
                viewStore.send(.checkAll)
            }, label: {
                HStack {
                    Text("Check all")
                }
            })

            Button(action: {
                print("Uncheck all")
                viewStore.send(.uncheckAll)
            }, label: {
                HStack {
                    Text("Uncheck all")
                }
            })
        }
    }
}

#Preview {
    PurchaseList(
        store: Store(initialState: PurchaseListFeature.demo,
                     reducer: { PurchaseListFeature()
                         .dependency(\.analyticsClient, AnalyticsClient.firebaseClient)}
                    )
    )
}
