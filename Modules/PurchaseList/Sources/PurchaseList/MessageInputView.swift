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
          WithViewStore(store,
                      observe: { $0 },
                      content: { viewStore in
            textView(with: viewStore)
            .padding(.bottom, 2.steps)
            .padding(.top, 1.steps)
            .padding(.horizontal, 4.steps)
        })
    }

    @ViewBuilder
    private func textView(with viewStore: ViewStoreOf<MessageInputFeature>) -> some View {
        HStack(alignment: .bottom, spacing: 4.steps) {

            scannerButton(viewStore)
                .padding(.bottom, 3.steps)

            VStack {
                textField(viewStore)
            }
            .background(.white)
            .cornerRadius(4.steps)
            .padding(.top, 2.steps)

            actionButton(viewStore)
                .padding(.bottom, 3.steps)
        }
    }

   private func textField(_ viewStore: ViewStoreOf<MessageInputFeature>) -> some View {
        TextField("", text: viewStore.binding(get: \.inputText,
                                              send: MessageInputFeature.Action.textChanged),
                  axis: .vertical)
            .accentColor(.black)
            .frame(maxWidth: .infinity)
            .padding(2.steps)
    }

    private func scannerButton(_ viewStore: ViewStoreOf<MessageInputFeature>) -> some View {
        Button(action: {
            viewStore.send(.tapOnScannerButton)
        },
               label: {
            Image(systemName: "doc.viewfinder")
                .foregroundColor(.black)
        })
        .background {
            Circle()
                .foregroundColor(.white)
                .frame(width: 10.steps, height: 10.steps)
        }
    
    }

    private func actionButton(_ viewStore: ViewStoreOf<MessageInputFeature>) -> some View {
        Button(action: {
            viewStore.send(.tapOnActionButton(viewStore.inputText))
        },
               label: {
            Image(systemName: "pencil") // Add your icon name here
                .foregroundColor(.black) // Customize icon color
        })
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
