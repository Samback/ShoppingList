//
//  SwiftUIView.swift
//
//
//  Created by Max Tymchii on 11.11.2023.
//

import SwiftUI
import Theme
import Inject

extension LinearGradient {
    static let lightTheme = LinearGradient(gradient:
                                            Gradient(colors: [Color(hex: 0x3DCF6A),
                                                              Color(hex: 0x114551)]),
                                          startPoint: .top,
                                          endPoint: .bottom)
    
    static let darkTheme = LinearGradient(gradient: 
                                            Gradient(colors: [Color(hex: 0x0A0B1A),
                                                              Color(hex: 0x114551)]),
                                          startPoint: .top,
                                          endPoint: .bottom)
}

struct SplashScreenView: View {

    @ObserveInjection var inject
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .center) {
                Spacer()
            Image(colorScheme == .light ? .splashScreenWhite : .splashScreenDark)
                .padding(.bottom, 32)

                Text(" PERO")
                    .font(Font.custom("SF Pro Rounded", size: 19)
                        .weight(.bold))
                    .tracking(20)
                    .foregroundColor(colorScheme == .light ? ColorTheme.live().surface_1 : ColorTheme.live().accent)

                Spacer()
                Spacer()
            }

            .frame(
                           width: UIScreen.main.bounds.width,
                           height: UIScreen.main.bounds.height + 32
                       )
        .edgesIgnoringSafeArea(.all)
        .background {
            colorScheme == .light ? LinearGradient.lightTheme : LinearGradient.darkTheme
        }
        .enableInjection()
    }

}

#Preview {
    SplashScreenView().preferredColorScheme(.light)
}

#Preview {
    SplashScreenView().preferredColorScheme(.dark)
}
