//
//  SwiftUIView.swift
//
//
//  Created by Max Tymchii on 17.10.2023.
//

import SwiftUI
import ComposableArchitecture
import Theme
import Inject

public struct DraftList: View {
    let store: StoreOf<DraftListFeature>

    @ObserveInjection var inject

    public init(store: StoreOf<DraftListFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store,
                      observe: {$0}) { viewStore in
            store.withState { _ in
                NavigationStack {
                    VStack {
                        TextEditor(text: viewStore.$inputText)
                            .foregroundStyle(ColorTheme.live().primary)
                            .font(.system(size: 22))
                            .lineSpacing(/*@START_MENU_TOKEN@*/10.0/*@END_MENU_TOKEN@*/)
                            .scrollIndicators(.hidden)
                    }
                    .padding()
                    .toolbar(content: {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                viewStore.send(.delegate(.cancel))
                            }, label: {
                                Text("Cancel")
                                    .navigationActionButtonTitleModifier()
                            })
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                viewStore.send(.tapOnAddAtShoppingList)
                            }, label: {
                                Text("Add to list")
                                    .navigationActionButtonTitleModifier()
                            })
                        }
                    })
                }
            }
        }.enableInjection()
    }

}

#Preview {
    DraftList(store: StoreOf<DraftListFeature>(initialState: DraftListFeature
        .State(rawList:
                ["This is a true story about my childhood",
                 "Milk",
                 "Bread"]),
                                               reducer: {
        DraftListFeature()
    }
    ))
}
