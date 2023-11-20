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
import Theme
import SwiftUIIntrospect
import UIKit
import Inject
import Tips
import TipKit

// https://www.hackingwithswift.com/quick-start/swiftui/how-to-add-custom-swipe-action-buttons-to-a-list-row
// https://www.swiftanytime.com/blog/contextmenu-in-swiftui

// https://kristaps.me/blog/swiftui-navigationview/

public struct PurchaseList: View {

    @ObserveInjection var inject

    @Environment(\.presentationMode) var presentation

    let store: StoreOf<PurchaseListFeature>

    public init(store: StoreOf<PurchaseListFeature>) {
        self.store = store
    }

    public var body: some View {

        WithViewStore(store,
                      observe: { $0 },
                      content: { viewStore in
            NavigationStack {
                ZStack {
                    listView(with: viewStore)
                        .safeAreaPadding(.bottom, 86)
                        .safeAreaPadding(.top, 16)
                        .ignoresSafeArea(.keyboard)
                        .background(.clear)
                    VStack(spacing: 0) {
                        Spacer()

                        inputView(with: viewStore)
                            .padding(.bottom, -34)
                            .ignoresSafeArea(.keyboard)
                    }
                    .background(.clear)
                }

                .background(.clear)
            }

            .onAppear {
                Appearance.apply()
                viewStore.send(.onAppear)
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle(viewStore.title)
            .toolbar(content: {
                toolbarView(with: viewStore)
            })

            .introspect(.viewController, on: .iOS(.v17)) { viewController in
                print("ViewController \(viewController)")

                viewController.setupCustomBigTitleRepresentation(counter: viewStore.counter)

            }
            .sheet(store: self.store.scope(state: \.$scanPurchaseList,
                                           action: {.scannerAction($0)}),
                   content: ScannerTCA.init)
            .sheet(store: self.store.scope(state: \.$draftList,
                                           action: {.draftListAction($0)}),
                   content: DraftList.init)
            .confirmationDialog(store: self.store.scope(state: \.$confirmationDialog,
                                                        action: { .confirmationDialog($0) }))
            .enableInjection()
        })

    }

    private func toolbarView(with viewStore: ViewStoreOf<PurchaseListFeature>) -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                viewStore.send(.tapOnResizeButton)
            }, label: {
                viewStore.viewMode
                    .invertedValue
                    .image
                    .renderingMode(.template)
                    .tint(ColorTheme.live().accent)
            })
        }
    }

    @ViewBuilder
    private func inputView(with viewStore: ViewStoreOf<PurchaseListFeature>) -> some View {
        MessageInputView(store:
                            self.store.scope(state: \.inputField, action: PurchaseListFeature.Action.inputTextAction))
    }

    @ViewBuilder
    private func listView(with viewStore: ViewStoreOf<PurchaseListFeature>) -> some View {
        List {
//            TipView(ChangeOrderTip())
            ForEachStore(
                self
                    .store
                    .scope(state: \.notes,
                           action: PurchaseListFeature.Action.notesAction(id:action:))) { itemStore in
                               NoteView(store: itemStore)
                                   .swipeActions {
                                       itemStore.withState { localState in
                                           HStack {
                                               Button(
                                                action: {
                                                    viewStore
                                                        .send(
                                                            .contextMenuAction(
                                                            .deleteNote(localState.id)))
                                                }, label: {
                                                    HStack {
                                                        Text("Delete")
                                                    }
                                                })
                                               .tint(ColorTheme.live().destructive)

                                               Button(action: {
                                                   viewStore.send(.showConfirmationDialog(localState.id))
                                               }, label: {
                                                   Text("Options")
                                               })
                                               .tint(ColorTheme.live().secondary)
                                           }
                                       }
                                   }
                                   .contextMenu {
                                       itemStore.withState { state in
                                           contextMenuItems(with: viewStore, item: state)
                                       }
                                   }
                                   .listRowInsets(.init(top: 0, leading: 24, bottom: 0, trailing: 0))
                                   .listRowSeparatorTint(ColorTheme.live().separator)
                                   .frame(height: viewStore.viewMode.height)

                           }
                           .onDelete { viewStore.send(.delete($0))}
                           .onMove { viewStore.send(.move($0, $1))}
                           .listSectionSeparator(.hidden, edges: .top)

        }
        .listStyle(.plain)
        .environment(\.defaultMinListRowHeight, 10)
    }

    @ViewBuilder
    private func contextMenuItems(with viewStore: ViewStoreOf<PurchaseListFeature>,
                                  item state: NoteFeature.State) -> some View {
        Group {
            Button(action: {
                print("Tap on edit")
            viewStore.send(.contextMenuAction(.edit(state.id)))
            }, label: {
                HStack {
                    Text("Edit")
                    Spacer()
                    Image(systemName: "pencil")
                }
            })

            Button(action: {
                print("Tap on duplicate")
                viewStore.send(.contextMenuAction(.duplicate(state.id)))
            }, label: {
                HStack {
                    Text("Duplicate")
                    Spacer()
                    Image(systemName: "doc.on.doc")
                }
            })

            Divider()

            Button(
                role: .destructive,
                action: {
                    viewStore.send(.contextMenuAction(.deleteNote(state.id)))
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
    NavigationStack {
        PurchaseList(
            store: Store(initialState: PurchaseListFeature.demo,
                         reducer: { PurchaseListFeature()
                             .dependency(\.analyticsClient, AnalyticsClient.firebaseClient)}
                        )
        )
    }
}
