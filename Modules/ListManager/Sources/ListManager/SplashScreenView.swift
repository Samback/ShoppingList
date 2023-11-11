//
//  SwiftUIView.swift
//
//
//  Created by Max Tymchii on 11.11.2023.
//

import SwiftUI
import Theme

struct SplashScreenView: View {
    var body: some View {
        VStack(alignment: .center) {
                Spacer()
                Image(.splashScreenWhite)
                    .padding(.bottom, 32)

                Text(" PERO")
                    .font(Font.custom("SF Pro Rounded", size: 19)
                        .weight(.bold))
                    .tracking(20)
                    .foregroundColor(.white)

                Spacer()
                Spacer()
            }

            .frame(
                           width: UIScreen.main.bounds.width,
                           height: UIScreen.main.bounds.height + 32
                       )
        .edgesIgnoringSafeArea(.all)
        .background {
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.24, green: 0.81, blue: 0.42), Color(red: 0.32, green: 0.89, blue: 0.49)]), startPoint: .top, endPoint: .bottom)
        }
    }

}

#Preview {
    SplashScreenView()
}
