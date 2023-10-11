//
//  InputView.swift
//  ShoppingNotes
//
//  Created by Max Tymchii on 15.08.2023.
//

import SwiftUI
import ComposableArchitecture
import Utils

struct MessageInputView: View {
    let store: StoreOf<MessageInputFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(alignment: .bottom, spacing: 4.steps) {
                VStack {
                   textField(viewStore)
                }
                .background(.white)
                .cornerRadius(4.steps)

                actionButton(viewStore)
                    .padding(.bottom, 3.steps)
            }
            .padding(.bottom, 2.steps)
            .padding(.top, 1.steps)
            .padding(.horizontal, 4.steps)
        }
    }

   private func textField(_ viewStore: ViewStore<MessageInputFeature.State, MessageInputFeature.Action>) -> some View {
        TextField("", text: viewStore.binding(get: \.inputText,
                                              send: MessageInputFeature.Action.textChanged),
                  axis: .vertical)
            .lineLimit(1...4)
            .accentColor(.black)
            .frame(maxWidth: .infinity)
            .padding(2.steps)
    }


    private func actionButton(_ viewStore: ViewStore<MessageInputFeature.State, MessageInputFeature.Action>) -> some View {
        Button(action: {
            viewStore.send(.tapOnActionButton(viewStore.inputText))
        }) {
            Image(systemName: "pencil") // Add your icon name here
                .foregroundColor(.black) // Customize icon color
        }
        .background {
            Circle()
                .foregroundColor(.white)
                .frame(width: 10.steps, height: 10.steps)
        }

    }

}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            
            MessageInputView(store:
Store(initialState:
        MessageInputFeature.State(inputText: "Some text")) {
                MessageInputFeature()
            })
            .background(.red)
        }
        .background(.black.opacity(0.2))
    }
}
