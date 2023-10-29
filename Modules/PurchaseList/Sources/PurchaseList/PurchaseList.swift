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

// https://www.hackingwithswift.com/quick-start/swiftui/how-to-add-custom-swipe-action-buttons-to-a-list-row
// https://www.swiftanytime.com/blog/contextmenu-in-swiftui

// https://kristaps.me/blog/swiftui-navigationview/

public struct PurchaseList: View {

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
                    VStack(spacing: 0) {
                        listView(with: viewStore)
                            .background(.clear)
                        inputView(with: viewStore)
                    }
                    .background(.clear)
                }
                .onAppear {
                    viewStore.send(.onAppear)
                    Appearance.apply()
                }
                .scrollDismissesKeyboard(.immediately)
                .navigationTitle(viewStore.title)
                .toolbar(content: {
                    toolbarView(with: viewStore)
                })
                .navigationBarBackButtonHidden(true)
                .toolbar(content: {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            self.presentation.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                             .foregroundColor(ColorTheme.live().accent)
                        }
                        }
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
            Button(action: {
                viewStore.send(.tapOnResizeButton)
            }, label: {
                viewStore.viewMode
                    .invertedValue
                    .image
                    .renderingMode(.original)
                    .tint(ColorTheme.live().accent)
            })
        }
    }

    @ViewBuilder
    private func inputView(with viewStore: ViewStoreOf<PurchaseListFeature>) -> some View {
        MessageInputView(store:
                            self.store.scope(state: \.inputField, action: PurchaseListFeature.Action.inputTextAction))
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
                                               Button(
                                                role: .destructive,
                                                action: {
                                                    viewStore.send(.deleteNote(localState.id))
                                                }, label: {
                                                    HStack {
                                                        Text("Delete")
                                                    }
                                                })

                                               Button(action: {
                                                   print("Options")
                                               }, label: {
                                                   Text("Options")
                                               })

                                           }
                                       }
                                   }
                                   .contextMenu {
                                       itemStore.withState { state in
                                           contextMenuItems(with: viewStore, item: state)
                                       }
                                   }
                                   .listRowInsets(.init(top: 0, leading: 24, bottom: 0, trailing: 0))
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
                viewStore.send(.edit(state.id))
            }, label: {
                HStack {
                    Text("Rename")
                    Spacer()
                    Image(systemName: "character.cursor.ibeam")
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

            Divider()

            Button(
                role: .destructive,
                action: {
                    viewStore.send(.deleteNote(state.id))
                }, label: {
                    HStack {
                        Text("Delete")
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
