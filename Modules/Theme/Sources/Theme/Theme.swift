import SwiftUI

// https://sarunw.com/posts/how-to-define-custom-environment-values-in-swiftui/

public extension Color {
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


private extension UIColor {
    convenience init(hex: UInt, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat((hex & 0x0000FF) >> 0) / 255.0,
            alpha: alpha
        )
    }
}

extension UIBlurEffect.Style {
    init(dynamicProvider: @escaping (UITraitCollection) -> UIBlurEffect.Style) {
        self = .light // Provide a default style

        // Update the style based on the dynamicProvider
        updateStyle(with: dynamicProvider)
    }

    private mutating func updateStyle(with dynamicProvider: (UITraitCollection) -> UIBlurEffect.Style) {
        // Capture the original style
        let originalStyle = self

        // Temporarily change the trait collection and update the style
        UITraitCollection.current.performAsCurrent {
            print("Change trait collection to current")
            self = dynamicProvider(UITraitCollection.current)
        }

        // Restore the original style after the closure
        self = originalStyle
    }
}



public struct ColorTheme {

    public var primary: Color {
        _ = blurEffectStyle
        return ColorScheme.getColor(for: \.primary)
    }
    
    public var secondary: Color {
        return ColorScheme.getColor(for: \.secondary)
    }
    
    public var separator: Color {
        return ColorScheme.getColor(for: \.separator)
    }
    
    public var accent: Color {
        return ColorScheme.getColor(for: \.accent)
    }
    
    public var destructive: Color {
        return ColorScheme.getColor(for: \.destructive)
    }
    
    public var surface_1: Color {
        return ColorScheme.getColor(for: \.surface_1)
    }
    
    public var surface_2: Color {
        return ColorScheme.getColor(for: \.surface_2)
    }
    
    public var surface_3: Color {
        return ColorScheme.getColor(for: \.surface_3)
    }
    
    public var surface_4: Color {
        return ColorScheme.getColor(for: \.surface_4)
    }
    
    public var surface_5: Color {
        return ColorScheme.getColor(for: \.surface_5)
    }
    
    public var surface_6: Color {
        return ColorScheme.getColor(for: \.surface_6)
    }
    
    
    
    public var blurEffectStyle: UIBlurEffect.Style {
        if case .dark = UITraitCollection.current.userInterfaceStyle {
            return .dark
        }
        else {
            return .light
        }
    }

       
        
    static var theme = ColorTheme()

   public static var live: @Sendable () -> Self = {
       return ColorTheme.theme
    }
}


struct ColorScheme {
    
    public var primary: UIColor
    public var secondary: UIColor
    public var separator: UIColor
    public var accent: UIColor
    public var destructive: UIColor
    public var surface_1: UIColor
    public var surface_2: UIColor
    public var surface_3: UIColor
    public var surface_4: UIColor
    public var surface_5: UIColor
    public var surface_6: UIColor
    
    static func getColor<T>(for keyPath: KeyPath<ColorScheme, T>) -> Color {
        return Color(UIColor { traitCollection in
            if case .dark = traitCollection.userInterfaceStyle {
                return ColorScheme.blackColorTheme[keyPath: keyPath] as? UIColor ?? .black
            }
            else {
                return ColorScheme.lightColorTheme[keyPath: keyPath] as? UIColor ?? .black
            }
        }
        )
    }
    
    static var lightColorTheme: ColorScheme = .init(primary: UIColor.init(hex: 0x064F60),
                                                          secondary: .init(hex: 0x9BADB0),
                                                          separator: .init(hex: 0xE7E8E9),
                                                          accent: .init(hex: 0x3DCF6A),
                                                          destructive: .init(hex: 0xFF2D55),
                                                          surface_1: .init(hex: 0xFFFFFF),
                                                          surface_2: .init(hex: 0xFFFFFF),
                                                          surface_3: .init(hex: 0x9BADB0).withAlphaComponent(0.15),
                                                          surface_4: .init(hex: 0xFFFFFF).withAlphaComponent(0.2),
                                                          surface_5: .init(hex: 0x9BADB0).withAlphaComponent(0.15),
                                                          surface_6: .init(hex: 0x9BADB0).withAlphaComponent(0.5)
   )
   
    static var blackColorTheme: ColorScheme = .init(primary: UIColor.init(hex: 0xFFFFFF),
                                                          secondary: .init(hex: 0x74888B),
                                                          separator: .init(hex: 0x064F60).withAlphaComponent(0.5),
                                                          accent: .init(hex: 0x52E27E),
                                                          destructive: .init(hex: 0xFF375F),
                                                          surface_1: .init(hex: 0x091315),
                                                          surface_2: .init(hex: 0x09272E),
                                                          surface_3: .init(hex: 0x09272E).withAlphaComponent(0.4),
                                                          surface_4: .init(hex: 0x09272E).withAlphaComponent(0.2),
                                                          surface_5: .init(hex: 0x09272E),
                                                          surface_6: .init(hex: 0x9BADB0).withAlphaComponent(0.5)
   )
}
