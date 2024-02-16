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
    @ObservableState
    public struct State: Equatable {

        public init() {}

        public var isPresented: Bool = true
        public var texts: [String] = []
    }

    @CasePathable
    public enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding(\.isPresented):
                print("Hide and sick \(state.isPresented)")
            case .binding(\.texts):
                print("Texts \(state.texts)")
            default:
                break
            }
            return .none
        }
    }

}

public struct ScannerView: View {

    @Bindable var store: StoreOf<ScannerFeature>

    public init(store: StoreOf<ScannerFeature>) {
        self.store = store
    }

    public var body: some View {
            VStack {
                ScannerFlowView(isPresented: $store.isPresented,
                                texts: $store.texts)
                .ignoresSafeArea(.container)
            }
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
    }
}

#Preview {
    ScannerView(store:
            .init(initialState: ScannerFeature.State(),
                  reducer: { ScannerFeature() }
                 )
    )
}
