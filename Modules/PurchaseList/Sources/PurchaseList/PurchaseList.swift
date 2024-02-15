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
    
    @Bindable var store: StoreOf<PurchaseListFeature>
    
    public init(store: StoreOf<PurchaseListFeature>) {
        self.store = store
    }
    
    public var body: some View {
        
        NavigationStack {
            ZStack {
                listView()
                    .safeAreaPadding(.bottom, 86)
                    .safeAreaPadding(.top, 16)
                    .ignoresSafeArea(.keyboard)
                    .background(.clear)
                VStack(spacing: 0) {
                    Spacer()
                    
                    inputView()
                        .padding(.bottom, -34)
                        .ignoresSafeArea(.keyboard)
                }
                .background(.clear)
            }
            
            .background(.clear)
        }
        
        .onAppear {
            Appearance.apply()
            store.send(.onAppear)
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle(store.title)
        .toolbar(content: toolbarView)
        
        .introspect(.viewController, on: .iOS(.v17)) { viewController in
            print("ViewController \(viewController)")
            
            viewController.setupCustomBigTitleRepresentation(counter: store.counter)
            
        }
        
        .sheet(store: self.store.scope(state: \.$scanPurchaseList,
                                       action: \.scannerAction),
               content: ScannerView.init)
        .confirmationDialog(store: self.store.scope(state: \.$confirmationDialog,
                                                    action: \.confirmationDialog))
        .enableInjection()
    }
    
    private func toolbarView() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                store
                    .send(.tapOnResizeButton)
            }, label: {
                store
                    .viewMode
                    .invertedValue
                    .image
                    .renderingMode(.template)
                    .tint(ColorTheme.live().accent)
            })
        }
    }
    
    @ViewBuilder
    private func inputView() -> some View {
        MessageInputView(store:
                            self.store.scope(state: \.inputField,
                                             action: \.inputTextAction))
    }
    
    @ViewBuilder
    private func listView() -> some View {
        List {
            //            TipView(ChangeOrderTip())
            ForEach(
                self
                    .store
                    .scope(state: \.notes,
                           action: \.noteActions),
                id: \.state.id) { itemStore in
                               NoteView(store: itemStore)
                                   .swipeActions {
                                       itemStore.withState { localState in
                                           HStack {
                                               Button(
                                                action: {
                                                    store
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
                                                   store.send(.showConfirmationDialog(localState.id))
                                               }, label: {
                                                   Text("Options")
                                               })
                                               .tint(ColorTheme.live().secondary)
                                           }
                                       }
                                   }
                                   .contextMenu {
                                       itemStore.withState { state in
                                           contextMenuItems(item: state)
                                       }
                                   }
                                   .listRowInsets(.init(top: 0, leading: 24, bottom: 0, trailing: 0))
                                   .listRowSeparatorTint(ColorTheme.live().separator)
                                   .frame(height: store.viewMode.height)
                               
                           }
                           .onDelete { store.send(.delete($0))}
                           .onMove { store.send(.move($0, $1))}
                           .listSectionSeparator(.hidden, edges: .top)
            
        }
        .listStyle(.plain)
        .environment(\.defaultMinListRowHeight, 10)
    }
    
    @ViewBuilder
    private func contextMenuItems(item state: NoteFeature.State) -> some View {
        Group {
            Button(action: {
                print("Tap on edit")
                store.send(.contextMenuAction(.edit(state.id)))
            }, label: {
                HStack {
                    Text("Edit")
                    Spacer()
                    Image(systemName: "pencil")
                }
            })
            
            Button(action: {
                print("Tap on duplicate")
                store.send(.contextMenuAction(.duplicate(state.id)))
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
                    store.send(.contextMenuAction(.deleteNote(state.id)))
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
