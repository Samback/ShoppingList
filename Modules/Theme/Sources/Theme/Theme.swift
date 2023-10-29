import SwiftUI
// https://sarunw.com/posts/how-to-define-custom-environment-values-in-swiftui/

extension Color {
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }

    var uiColor: UIColor {
        return UIColor(self)
    }
}

public struct ColorTheme {

    public var primary: Color
    public var secondary: Color
    public var accent: Color

   public  static var live: @Sendable () -> Self = {
        return lightColorTheme
    }

    private static var lightColorTheme: ColorTheme = .init(primary: Color.init(hex: 0x064F60),
                                                           secondary: .init(hex: 0x858F94),
                                                           accent: .init(hex: 0x61D384)

    )

}
