import Foundation
import TipKit
import Theme

public struct OrganiseListTip: Tip {

    public static let counter = Event(id: "organiseList.counter")

    public var title: Text {
        titleView("Organise your list")
    }

    public var message: Text? {
        messageView("Touch and hold a list for a moment. Then move up and down where you need to.")
    }

    public var image: Image? {
        Image(.drag)
    }

    public var rules: [Rule] {
        #Rule(Self.counter) {
            $0.donations.count >= 3
        }
    }

    public var options: [TipOption] {
        [Tip.MaxDisplayCount(2)]
    }

}
