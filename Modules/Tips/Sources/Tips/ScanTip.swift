//
//  File.swift
//
//
//  Created by Max Tymchii on 14.11.2023.
//

import Foundation
import TipKit
import Theme

public struct ScanTip: Tip {

    public init() {}

    public static let counter = Event(id: "scanTip.counter")

    public var title: Text {
        titleView("Scan & add to a list")
    }

    public var message: Text? {
        messageView("Turn any handwritten or typed text into your Pero list. Scan, edit, save. Voila! New items have been added to the list.")
    }

    public var image: Image? {
        Image(.scan)
    }

    public var rules: [Rule] {
        #Rule(Self.counter) {
            $0.donations.count >= 3
        }
    }

    public var options: [TipOption] {
        [Tip.MaxDisplayCount(3)]
    }
}
