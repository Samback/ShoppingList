//
//  File.swift
//  
//
//  Created by Max Tymchii on 14.11.2023.
//

import Foundation
import TipKit
import Theme

@available(iOS 17.0, *)
public extension Tip {

    func titleView(_ text: String) -> Text {
        Text(text)
            .foregroundColor(ColorTheme.live().primary)
            .font(.system(size: 20))
    }

    func messageView(_ text: String) -> Text {
        Text(text)
            .foregroundColor(ColorTheme.live().secondary)
            .font(.system(size: 17))
    }

    func configTipsStore() {
#if DEBUG
        /// Optionally, call `Tips.resetDatastore()` before `Tips.configure()` to reset the state of all tips. This will allow tips to re-appear even after they have been dismissed by the user.
        /// This is for testing only, and should not be enabled in release builds.
        try? Tips.resetDatastore()
#endif

        try? Tips.configure(
            [
                // Reset which tips have been shown and what parameters have been tracked, useful during testing and for this sample project
                .datastoreLocation(.applicationDefault),

                // When should the tips be presented? If you use .immediate, they'll all be presented whenever a screen with a tip appears.
                // You can adjust this on per tip level as well
                    .displayFrequency(.immediate)
            ]
        )
    }
}
