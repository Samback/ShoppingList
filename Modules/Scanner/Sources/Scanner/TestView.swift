//
//  SwiftUIView.swift
//
//
//  Created by Max Tymchii on 05.12.2023.
//

import SwiftUI

public struct TestView: View {

    @State var isPresented = true
    @State var texts: [String] = []
    public init() {}

    public var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/ + "\(texts.count)")
                .sheet(isPresented: $isPresented, content: {
                    ScannerFlowView(isPresented: $isPresented, texts: $texts)
                        .ignoresSafeArea(.container)
                })
        }
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
        .background(.yellow)

    }
}

#Preview {
    TestView()
}
