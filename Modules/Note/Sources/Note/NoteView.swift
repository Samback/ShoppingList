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

    var imageColor: Color {
        switch self {
        case .new:
            return ColorTheme.live().secondary
        case .done:
            return ColorTheme.live().accent
        }
    }

    var image: Image {
        switch self {
        case .new:
            return Image(.todo).renderingMode(.template)
        case .done:
            return Image(.done).renderingMode(.template)
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
    @Bindable var store: StoreOf<NoteFeature>

    public init(store: StoreOf<NoteFeature>) {
        self.store = store
    }

    public var body: some View {

            VStack(spacing: 0) {
                Spacer()
                Spacer()
                HStack(spacing: 0) {
                    Text(store.titlePrefix)
                        .modifier(PrefixTitleModifier(status: store.status))
                    Text(store.titleSuffix)
                        .modifier(SuffixTitleModifier(status: store.status))

                    Spacer()
                    store
                        .status
                        .image
                        .foregroundColor(store.status.imageColor)
                        .padding(.trailing, 24)
                }
                .frame(maxWidth: .infinity)
                Spacer()
            }
                                   .background(ColorTheme.live().surface_1)
            .contentShape(Rectangle())
            .onTapGesture {
                store.status.toggle()
            }
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
