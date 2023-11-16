import Foundation
import TipKit
import Theme

public struct ChangeOrderTip: Tip {

    public static let counter = Event(id: "changeOrderTip.counter")

    public init() {}
    public var title: Text {
        titleView("Change the order")
    }

    public var message: Text? {
        messageView("Touch and hold an item for a moment. Then move up and down where you need to.")
    }

    public var image: Image? {
        Image(.drag)
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
