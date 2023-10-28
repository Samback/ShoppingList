//
//  NoteView.swift
//  ShoppingList
//
//  Created by Max Tymchii on 21.09.2023.
//

import SwiftUI
import ComposableArchitecture

extension NoteFeature.Status {

    var color: Color {
        switch self {
        case .new:
            return .black
        case .done:
            return .green
        }
    }

    var imageName: String {
        switch self {
        case .new:
            return "plus"
        case .done:
            return "checkmark"
        }
    }
}

struct ActionButtonModifier: ViewModifier {
    let status: NoteFeature.Status

    func body(content: Content) -> some View {
        ZStack {
            content
            Circle()
                .stroke(lineWidth: 3)
                .padding(10)
            Image(systemName: status.imageName)
                .font(.body)
        }
        .foregroundColor(status.color)
    }
}

#Preview {
    HStack {
        Text(" ")
            .modifier(ActionButtonModifier(status: .done))
        Text(" ")
            .modifier(ActionButtonModifier(status: .new))

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
                    textView(viewStore.title)
                        .foregroundStyle(viewStore.status.color)

                    Spacer()

                    Button(action: {
                        viewStore.$status.wrappedValue.toggle()
                    }, label: {
                        Image(systemName: viewStore.status.imageName)
                            .modifier(ActionButtonModifier(status: viewStore.status))
                    })
                    .frame(width: 44, height: 44)
                    .buttonStyle(.plain)
                }

                Spacer()
            }

        })
    }

    private func textView(_ text: String) -> some View {
        HStack(spacing: 0) {
            Text(String(text.prefix(3))).font(.system(size: 22, weight: .semibold))
            Text(String(text.dropFirst(3))).font(.system(size: 22, weight: .regular))
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
        .background(.red)
    }
    .background(.blue)
}
