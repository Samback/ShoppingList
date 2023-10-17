//
//  SwiftUIView.swift
//
//
//  Created by Max Tymchii on 17.10.2023.
//

import SwiftUI
import ComposableArchitecture

public struct DraftList: View {
    let store: StoreOf<DraftListFeature>

    public init(store: StoreOf<DraftListFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store,
                      observe: {$0}) { viewStore in
            store.withState { state in
                NavigationStack {
                    VStack {
                        TextEditor(text: viewStore.$inputText)
                    }
                    .padding()
                    .toolbar(content: {
                        Button(action: {
                            viewStore.send(.tapOnAddAtShoppingList)
                        }, label: {
                            Text("Save")
                        })
                    })
                }
            }
        }
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
