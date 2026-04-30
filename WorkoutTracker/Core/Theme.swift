import SwiftUI

struct AppTheme {
    struct Colors {
        static let background = Color("AppBackground") // System-dependent or custom
        static let primary = Color.blue
        static let secondary = Color.purple
        static let accent = Color.orange
        static let cardBackground = Color(.secondarySystemBackground)
        static let textPrimary = Color.primary
    }
    
    struct Fonts {
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title = Font.system(size: 22, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 17, weight: .regular, design: .default)
        static let caption = Font.system(size: 14, weight: .medium, design: .default)
    }
    
    static func cardStyle() -> some ViewModifier {
        CardModifier()
    }
}

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
