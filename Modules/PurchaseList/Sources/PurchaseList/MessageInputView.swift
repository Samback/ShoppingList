//
//  InputView.swift
//  ShoppingNotes
//
//  Created by Max Tymchii on 15.08.2023.
//

import SwiftUI
import ComposableArchitecture
import Utils
import Theme

// https://stackoverflow.com/questions/56610957/is-there-a-method-to-blur-a-background-in-swiftui

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

public struct MessageInputView: View {
    let store: StoreOf<MessageInputFeature>

    @FocusState var focusedField: MessageInputFeature.State.Field?

    public init(store: StoreOf<MessageInputFeature>, focusedField: MessageInputFeature.State.Field? = nil) {
        self.store = store
        self.focusedField = focusedField
    }
    public var body: some View {
        WithViewStore(store,
                      observe: { $0 },
                      content: { viewStore in

            ZStack(alignment: .bottom) {

                HStack(spacing: 0) {
                    textView(with: viewStore)
                        .bind(viewStore.$focusedField, to: self.$focusedField)
                }
                .padding(.leading, viewStore.mode.leadingOffset)
                .padding(.top, 16)
                .padding(.bottom, 50)
                .padding(.trailing, 16)

                HStack(spacing: 0) {
                    if viewStore.isScannerEnabled {
                        scannerButton(viewStore)
                            .padding(.leading, 24)
                            .padding(.bottom, 70)
                    }

                    Spacer()
                    actionButton(viewStore)
                        .padding(.trailing, 24)
                        .padding(.bottom, 70)
                }
                .background(.clear)
                .padding(.trailing, 16)
            }
            .background {
                VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                    .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            }

        })
    }

    @ViewBuilder
    private func textView(with viewStore: ViewStoreOf<MessageInputFeature>) -> some View {
            textField(viewStore)
                .padding(.leading, 8)
                .padding(.trailing, 56)
        .frame(minHeight: 56)
        .frame(maxWidth: .infinity)
        .background(
          RoundedRectangle(cornerRadius: 12)
            .fill(ColorTheme.live().white)
        )

    }

    private func textField(_ viewStore: ViewStoreOf<MessageInputFeature>) -> some View {
        TextField(viewStore.mode.placeholderText,
                  text: viewStore.binding(get: \.inputText,
                                              send: MessageInputFeature.Action.textChanged),
                  prompt: Text(viewStore.mode.placeholderText)
            .foregroundColor(ColorTheme.live().secondary),
                  axis: .vertical)

        .textFieldStyle(.plain)
        .foregroundColor(ColorTheme.live().primary)
        .accentColor(ColorTheme.live().primary)
        .background(.clear)
        .focused($focusedField, equals: .inputMessage)
    }

    private func scannerButton(_ viewStore: ViewStoreOf<MessageInputFeature>) -> some View {
        Button(action: {
            viewStore.send(.tapOnScannerButton)
        },
               label: {
            Image(systemName: "text.viewfinder")
                .foregroundColor(ColorTheme.live().accent)
        })
        .background {
            Circle()
                .fill(ColorTheme.live().white)
                .frame(width: 40, height: 40)
        }

    }

    private func actionButton(_ viewStore: ViewStoreOf<MessageInputFeature>) -> some View {
        Button(action: {
            viewStore.send(.tapOnActionButton(viewStore.inputText, viewStore.mode))
        },
               label: {
            viewStore.mode.actionButtonImage.foregroundColor(ColorTheme.live().white)
        })
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(viewStore.isActionButtonEnabled ? ColorTheme.live().accent : ColorTheme.live().separator)
                .frame(width: 40, height: 40)
        }

    }

}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            VStack {
                Spacer()
            }
            .background(.red)

            VStack(alignment: .leading) {
                Spacer()

                MessageInputView(store:
                                    Store(initialState:
                                            MessageInputFeature.State(inputText: "Some text")) {
                    MessageInputFeature()
                })
            }
        }
        .background(.gray)

    }
}
