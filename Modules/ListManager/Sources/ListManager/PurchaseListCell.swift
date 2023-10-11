//
//  SwiftUIView.swift
//  
//
//  Created by Max Tymchii on 30.09.2023.
//

import SwiftUI
import UIKit



struct PurchaseListCell: View {

    let title: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(radius: 5)
            VStack(alignment: .leading) {
                Text(title)
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    .padding(.horizontal, 20)
            }.frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
        }
        .frame(maxWidth: .infinity)

    }
}

#Preview {
    VStack(alignment: .leading) {
            PurchaseListCell(title: "Name")
            .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
    }
    .padding()
    .background(.green)
}
