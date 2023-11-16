//
//  SwiftUIView.swift
//  
//
//  Created by Max Tymchii on 16.11.2023.
//

import SwiftUI
import TipKit
import Inject

public struct TipsTestingView: View {
    static let values = [0...10]
    let scannerTip = ScanTip()

    @ObserveInjection var inject

    public init() {}

    public var body: some View {
        VStack {
            TipView(ChangeOrderTip())
            TipView(OrganiseListTip())
            TipView(ScanTip())
            List {
                ForEach(Self.values, id: \.self) { value in
                    Text(value.description)
                }

            }
            VStack(spacing: 20) {
                Button("Lists tip donate") {
                    Task {
                     await OrganiseListTip.counter.donate()
                    }
                }

                Button("Product list tip donate") {
                    Task {
                     await ChangeOrderTip.counter.donate()
                    }
                }

                Button("Scanner button donate") {
//                    scannerTip.invalidate(reason: .actionPerformed)
                    Task {
                     await ScanTip.counter.donate()
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .enableInjection()
    }
}

#Preview {
    TipsTestingView()
}
