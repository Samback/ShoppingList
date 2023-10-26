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
                .scrollDismissesKeyboard(.immediately)
                .navigationTitle(viewStore.title)
                .toolbar {
                    toolbarView(with: viewStore)
                }
                .sheet(store: self.store.scope(state: \.$scanPurchaseList,
                                               action: {.scannerAction($0)}),
                       content: ScannerTCA.init)
                .sheet(store: self.store.scope(state: \.$draftList,
                                               action: {.draftListAction($0)}),
                       content: DraftList.init)
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
                           action: PurchaseListFeature.Action.notesAction(id:action:))) { itemStore in
                               NoteView(store: itemStore)
                                   .contextMenu {
                                       itemStore.withState { state in
                                           contextMenuItems(with: viewStore, item: state)
                                       }
                                   }
                           }
                           .onDelete { viewStore.send(.delete($0))}
                           .onMove { viewStore.send(.move($0, $1))}
        }

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
