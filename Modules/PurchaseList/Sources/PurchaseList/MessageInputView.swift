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
import Inject
import Tips

// https://stackoverflow.com/questions/56610957/is-there-a-method-to-blur-a-background-in-swiftui

public struct MessageInputView: View {
    @Bindable var store: StoreOf<MessageInputFeature>
    @Environment(\.colorScheme) var colorScheme

//    private let scanTip = ScanTip()

    @ObserveInjection var inject
    @State var id: UUID = UUID()
    @FocusState var focusedField: MessageInputFeature.State.Field?

    public init(store: StoreOf<MessageInputFeature>, focusedField: MessageInputFeature.State.Field? = nil) {
        self.store = store
        self.focusedField = focusedField
    }
    public var body: some View {

            ZStack(alignment: .bottom) {

                HStack(spacing: 0) {
                    textView()
                        .bind($store.focusedField, 
                              to: self.$focusedField)
                }
                .padding(.leading, store.mode.leadingOffset)
                .padding(.top, 16)
                .padding(.bottom, 50)
                .padding(.trailing, 16)

                HStack(spacing: 0) {

                    if store.isScannerEnabled {
                        scannerButton()
                            .onAppear {
//                                Task {
//                                    await ScanTip.counter.donate()
//                                }
                            }
                            .padding(.leading, 0)
                            .padding(.bottom, 46)
//                            .popoverTip(scanTip, arrowEdge: .bottom)
                    }

                    Spacer()

                    actionButton()
                        .padding(.trailing, 16)
                        .padding(.bottom, 46)
                }
                .background(.clear)
                .padding(.trailing, 0)
                .padding(.leading, 0)
            }
            .background {
                VisualEffect(colorTint: ColorTheme.live().surface_3,
                             colorTintAlpha: 0.2,
                             blurRadius: 16,
                             scale: 1)
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                .clipShape(
                    .rect(
                        topLeadingRadius: 10,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 10
                    )
                )
                .background(.clear)
            }
        .enableInjection()
    }

    @ViewBuilder
    private func textView() -> some View {
            textField()
                .padding(.leading, 16)
                .padding(.trailing, 56)
        .frame(minHeight: 56)
        .frame(maxWidth: .infinity)
        .background(
          RoundedRectangle(cornerRadius: 12)
            .fill(ColorTheme.live().surface_1)
        )

    }

    private func textField() -> some View {
        TextField(store.mode.placeholderText,
                  text: $store.inputText,
                  prompt: Text(store.mode.placeholderText)
            .foregroundColor(ColorTheme.live().secondary),
                  axis: .vertical)

        .textFieldStyle(.plain)
        .foregroundColor(ColorTheme.live().primary)
        .accentColor(ColorTheme.live().primary)
        .background(.clear)
        .focused($focusedField, equals: .inputMessage)
    }

    private func scannerButton() -> some View {
        Button(action: {
            store.send(.tapOnScannerButton)
        },
               label: {
            Image(systemName: "text.viewfinder")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(ColorTheme.live().accent)
        })
        .background {
            Circle()
                .fill(ColorTheme.live().surface_1)
                .frame(width: 40, height: 40)
        }
        .frame(width: 64, height: 64)

    }

    private func actionButton() -> some View {
        Button(action: {
            store.send(.tapOnActionButton(store.inputText, store.mode))
        },
               label: {
            store.mode.actionButtonImage
                .frame(width: 22, height: 22)
                .foregroundColor(ColorTheme.live().surface_1)
        })
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(store.isActionButtonEnabled ? ColorTheme.live().accent : ColorTheme.live().surface_5)
                .frame(width: 40, height: 40)
        }
        .frame(width: 64, height: 64)

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
