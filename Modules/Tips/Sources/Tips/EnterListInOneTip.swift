//
//  File.swift
//  
//
//  Created by Max Tymchii on 17.11.2023.
//

import Foundation
import TipKit
import Theme

public struct EnterListInOneTip: Tip {

    public static let counter = Event(id: "enterListInOneTip.counter")

    public init() {}
    public var title: Text {
        titleView("Enter list in one field")
    }

    public var message: Text? {
        Text("Enter as many items as you wish line by line using “Return” button. Tap the “\(Image(systemName: "plus"))” and get your list.")
            .foregroundColor(ColorTheme.live().secondary)
            .font(.system(size: 17))
    }

    public var image: Image? {
        Image(.enter)
    }

    public var rules: [Rule] {
        #Rule(Self.counter) {
            $0.donations.count >= 5
        }
    }

    public var options: [TipOption] {
        [Tip.MaxDisplayCount(2)]
    }

}
