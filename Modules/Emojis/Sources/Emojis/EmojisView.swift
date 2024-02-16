//
//  EmojisView.swift
//  Created by Max Tymchii on 03.11.2023.
//

import SwiftUI
import Theme
import MCEmojiPicker
import ComposableArchitecture

@Reducer
public struct EmojisFeature {

    public init() {}

    @ObservableState
    public struct State: Equatable {

        public init(selectedEmoji: String, id: UUID) {
            self.selectedEmoji = selectedEmoji
            self.id = id
        }

        var selectedEmoji: String
        let id: UUID
    }

    @CasePathable
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
            case .binding(\.selectedEmoji):
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
    @Bindable public var store: StoreOf<EmojisFeature>

    public init(store: StoreOf<EmojisFeature>) {
        self.store = store
    }

    public var body: some View {
            NavigationStack {
                VStack(spacing: 0) {
                    emojiView($store.selectedEmoji.wrappedValue)
                    EmojiViewControllerRepresentable(selectedEmoji: $store.selectedEmoji)
                }
                .background(ColorTheme.live().white)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    toolbarContent()
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
                        .fill(ColorTheme.live().surface)
                            .frame(width: 60, height: 60)
                              }
                .frame(height: 60)
            Spacer()
        }
        .frame(maxHeight: 80)

    }

    private func toolbarContent() -> some ToolbarContent {
       return Group {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    store.send(.cancel)
                }, label: {
                    Text("Cancel")
                        .navigationActionButtonTitleModifier()
                })
                .foregroundStyle(ColorTheme.live().accent)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    store.send(.emojiSaved(store.selectedEmoji, store.id))
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
