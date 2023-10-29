//
//  SwiftUIView.swift
//
//
//  Created by Max Tymchii on 28.10.2023.
//

import SwiftUI
import ComposableArchitecture
import Smile

public struct EmojiViewFeature: Reducer {
    @Dependency(\.emojiServiceProvider) var emojiServiceProvider

    public init() {

    }

    public struct State: Equatable {
        var emoji: String = ""
        var emojisPull: [Emoji]

       public init(emoji: String, emojisPull: [Emoji]) {
            self.emoji = emoji
            self.emojisPull = emojisPull
        }
    }

    public enum Action: Equatable {
        case loadEmojis
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadEmojis:
                state.emojisPull = emojiServiceProvider.loadEmojis()
                return .none
            }
        }

    }
}

public struct EmojiView: View {

    private let store: StoreOf<EmojiViewFeature>

    public init(store: StoreOf<EmojiViewFeature>) {
        self.store = store
        store.send(.loadEmojis)
    }

    let rows = [
        GridItem(.adaptive(minimum: 32))
       ]

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationView {
                ScrollView(.horizontal) {
                    LazyHGrid(rows: rows) {
                        ForEach(viewStore.emojisPull, id: \.self) { emoji in
                            Text(emoji.value)
                                .font(.title2)
                                .onTapGesture {
                                }
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal)

//                                .searchable(text: $search)

                }

            }

        }
    }
}

#Preview {
    VStack {
        EmojiView(store: StoreOf<EmojiViewFeature>.init(initialState: EmojiViewFeature.State(emoji: "", emojisPull: []), reducer: {
            EmojiViewFeature()
        }))
    }
}
