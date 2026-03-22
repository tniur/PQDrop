//
//  PQButtonType.swift
//  PQUIComponents
//
//  Created by Анастасия Журавлева on 16.02.2026.
//

import SwiftUI

public enum PQButtonType {
    case primary
    case purple
    case secondary
    case tertiary

    public var backgroundColor: SwiftUI.Color {
        switch self {
        case .primary:
            PQColor.base0.swiftUIColor
        case .purple:
            PQColor.blue6.swiftUIColor
        case .secondary, .tertiary:
            .clear
        }
    }

    public var foregroundColor: SwiftUI.Color {
        switch self {
        case .primary:
            PQColor.base10.swiftUIColor
        case .purple, .secondary, .tertiary:
            PQColor.base0.swiftUIColor
        }
    }

    public var strokeColor: SwiftUI.Color {
        switch self {
        case .primary, .purple, .tertiary:
            .clear
        case .secondary:
            PQColor.base0.swiftUIColor
        }
    }

    public var pressedBackgroundColor: SwiftUI.Color {
        switch self {
        case .primary:
            PQColor.base2.swiftUIColor
        case .purple:
            PQColor.blue8.swiftUIColor
        case .secondary, .tertiary:
            .clear
        }
    }

    public var pressedForegroundColor: SwiftUI.Color {
        switch self {
        case .primary:
            PQColor.base10.swiftUIColor
        case .purple:
            PQColor.base0.swiftUIColor
        case .secondary, .tertiary:
            PQColor.base3.swiftUIColor
        }
    }

    public var pressedStrokeColor: SwiftUI.Color {
        switch self {
        case .primary, .purple, .tertiary:
            .clear
        case .secondary:
            PQColor.base3.swiftUIColor
        }
    }

    public var disabledBackgroundColor: SwiftUI.Color {
        switch self {
        case .primary:
            PQColor.blue1.swiftUIColor
        case .purple:
            PQColor.blue3.swiftUIColor
        case .secondary, .tertiary:
            .clear
        }
    }

    public var disabledForegroundColor: SwiftUI.Color {
        switch self {
        case .primary:
            PQColor.base4.swiftUIColor
        case .purple:
            PQColor.blue2.swiftUIColor
        case .secondary, .tertiary:
            PQColor.base2.swiftUIColor
        }
    }

    public var disabledStrokeColor: SwiftUI.Color {
        switch self {
        case .primary, .purple, .tertiary:
            .clear
        case .secondary:
            PQColor.base2.swiftUIColor
        }
    }

    public var strokeWidth: CGFloat {
        switch self {
        case .primary, .purple, .tertiary:
            .zero
        case .secondary:
            1
        }
    }
}
