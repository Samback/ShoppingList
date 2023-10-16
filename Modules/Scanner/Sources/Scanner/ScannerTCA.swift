//
//  File.swift
//  
//
//  Created by Max Tymchii on 16.10.2023.
//

import Foundation
import ComposableArchitecture
import SwiftUI

public struct ScannerTCA: View {

    let store: StoreOf<ScannerTCAFeature>

    public init(store: StoreOf<ScannerTCAFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack {
            WithViewStore(store,
                          observe: { $0 },
                         content: { viewStore in
                store.withState { _ in
                    ScannerView()
                        .onAppear {
                            viewStore
                                .send(
                                    .initialLoad(publisher: Environment(\.scannerViewAction).wrappedValue))
                        }
                }
            }
            )
        }
    }

}

#Preview {
    ScannerTCA(store: StoreOf<ScannerTCAFeature>(initialState: ScannerTCAFeature.State(),
                              reducer: {
        ScannerTCAFeature()
    }))
}
