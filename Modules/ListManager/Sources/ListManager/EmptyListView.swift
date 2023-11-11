//
//  SwiftUIView.swift
//  
//
//  Created by Max Tymchii on 11.11.2023.
//

import SwiftUI
import Theme

struct EmptyListView: View {
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Image(.emptylistLight)
            Text(
                """
                Tap “+” button below
                & create first list
                """)
            .multilineTextAlignment(.center)
            .font(.system(size: 22, weight: .regular))
            .foregroundStyle(ColorTheme.live().primary)

            Spacer()
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    VStack {
        EmptyListView()
    }
}
