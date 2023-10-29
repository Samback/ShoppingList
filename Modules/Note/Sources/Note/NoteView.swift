//
//  NoteView.swift
//  ShoppingList
//
//  Created by Max Tymchii on 21.09.2023.
//

import SwiftUI
import ComposableArchitecture
import Theme

extension NoteFeature.Status {

    var color: Color {
        switch self {
        case .new:
            return ColorTheme.live().primary
        case .done:
            return ColorTheme.live().secondary
        }
    }

    var image: Image {
        switch self {
        case .new:
            return Image(.todo)
        case .done:
            return Image(.done)
        }
    }
}

struct PrefixTitleModifier: ViewModifier {

    let status: NoteFeature.Status
    func body(content: Content) -> some View {
        content
            .foregroundColor(status.color)
            .font(.system(size: 22, weight: .semibold))
    }
}

struct SuffixTitleModifier: ViewModifier {

    let status: NoteFeature.Status
    func body(content: Content) -> some View {
        content
            .foregroundColor(status.color)
            .font(.system(size: 22, weight: .regular))
    }
}

public struct NoteView: View {
    let store: StoreOf<NoteFeature>

    public init(store: StoreOf<NoteFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store,
                      observe: { $0 },
                      content: { viewStore in

            VStack(spacing: 0) {
                Spacer()
                Spacer()
                HStack(spacing: 0) {
                    Text(viewStore.titlePrefix)
                        .modifier(PrefixTitleModifier(status: viewStore.status))
                    Text(viewStore.titleSuffix)
                        .modifier(SuffixTitleModifier(status: viewStore.status))

                    Spacer()
                    viewStore.status.image
                        .padding(.trailing, 24)
                }
                Spacer()
            }

        })
    }

}

#Preview {
    VStack {
        NoteView(store: StoreOf<NoteFeature>(initialState: .demo,
                                             reducer: {
            NoteFeature()
        }))
        .frame(height: 52)
    }
}
