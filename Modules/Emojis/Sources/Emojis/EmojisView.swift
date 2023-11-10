//
//  EmojisView.swift
//  Created by Max Tymchii on 03.11.2023.
//

import SwiftUI
import Theme
import MCEmojiPicker
import ComposableArchitecture

public struct EmojisFeature: Reducer {

    public init() {}

    public struct State: Equatable {

        public init(selectedEmoji: String, id: UUID) {
            self.selectedEmoji = selectedEmoji
            self.id = id
        }

        @BindingState var selectedEmoji: String
        let id: UUID
    }

    public enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case emojiSaved(String, UUID)
        case cancel
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { _, action in
            switch action {
            case .emojiSaved:
                return .none
            case .binding(\.$selectedEmoji):
                return .none
            case .binding:
                return .none
            case .cancel:
                return .none
            }
        }
    }
}

public struct EmojisView: View {
    public let store: StoreOf<EmojisFeature>

    public init(store: StoreOf<EmojisFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            NavigationStack {
                VStack(spacing: 0) {
                    emojiView(viewStore.$selectedEmoji.wrappedValue)
                    EmojiViewControllerRepresentable(selectedEmoji: viewStore.$selectedEmoji)
                }
                .background(ColorTheme.live().white)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    toolbarContent(with: viewStore)
                }
            }
        }

    }

    private func emojiView(_ emoji: String) -> some View {
        HStack(alignment: .top) {
            Spacer()
            Text(emoji)
                .font(.system(size: 34))
                .background {
                    Circle()
                        .fill(ColorTheme.live().surfaceSecondary)
                            .frame(width: 60, height: 60)
                              }
                .frame(height: 60)
            Spacer()
        }
        .frame(maxHeight: 80)

    }

    private func toolbarContent(with viewStore: ViewStoreOf<EmojisFeature>) -> some ToolbarContent {
       return Group {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    viewStore.send(.cancel)
                }, label: {
                    Text("Cancel")
                        .navigationActionButtonTitleModifier()
                })
                .foregroundStyle(ColorTheme.live().accent)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    viewStore.send(.emojiSaved(viewStore.selectedEmoji, viewStore.id))
                }, label: {
                    Text("Save")
                        .navigationActionButtonTitleModifier()
                })
                .foregroundStyle(ColorTheme.live().accent)
            }

            ToolbarItem(placement: .principal) {
                Text("Select emoji")
                    .navigationTitleModifier()
            }
        }
    }
}

#Preview {
    VStack {
        Spacer()
    }
    .background(.blue)
    .sheet(isPresented: .constant(true), content: {
        EmojisView(store: .init(initialState: EmojisFeature.State(selectedEmoji: "😃", id: UUID()), reducer: {
            EmojisFeature()
        }))
            .presentationDetents([.medium])
            .presentationBackground(.thinMaterial)
    })

}
