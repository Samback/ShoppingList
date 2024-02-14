//
//  SwiftUIView.swift
//
//
//  Created by Max Tymchii on 26.01.2024.
//

import SwiftUI
import ComposableArchitecture

@Reducer
public struct ScannerFeature {

    public init() {}
    public struct State: Equatable {

        public init() {}

        @BindingState public var isPresented: Bool = true
        @BindingState public var texts: [String] = []
    }

    @CasePathable
    public enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding(\.$isPresented):
                print("Hide and sick \(state.isPresented)")
            case .binding(\.$texts):
                print("Texts \(state.texts)")
            default:
                break
            }
            return .none
        }
    }

}

public struct ScannerView: View {

    let store: StoreOf<ScannerFeature>

    public init(store: StoreOf<ScannerFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store,
                      observe: { $0 },
                      content: { viewStore in
            VStack {
                ScannerFlowView(isPresented: viewStore.$isPresented,
                                texts: viewStore.$texts)
                .ignoresSafeArea(.container)
            }
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
        })

    }
}

#Preview {
    ScannerView(store:
            .init(initialState: ScannerFeature.State(),
                  reducer: { ScannerFeature() }
                 )
    )
}
