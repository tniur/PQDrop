//
//  PQButton.swift
//  PQUIComponents
//
//  Created by Анастасия Журавлева on 16.02.2026.
//

import SwiftUI

public struct PQButton<Label: View>: View {

    // MARK: - Properties

    private let action: () -> Void
    private let label: () -> Label
    private let style: PQButtonStyle
    @Environment(\.isEnabled)
    private var isEnabled

    // MARK: - Body

    public var body: some View {
        Button( action: action, label: label)
            .buttonStyle(style)
            .disabled(!isEnabled)
    }

    // MARK: - Initialzer

    public init(
        style: PQButtonStyle = .init(.primary),
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.action = action
        self.label = label
        self.style = style
    }
}

// MARK: - Label == Text

public extension PQButton where Label == Text {

    init(
        _ titleKey: String,
        style: PQButtonStyle = .init(.primary),
        action: @escaping () -> Void
    ) {
        self.init(style: style, action: action) {
            Text(titleKey)
        }
    }

    init(
        _ titleKey: LocalizedStringKey,
        style: PQButtonStyle = .init(.primary),
        action: @escaping () -> Void
    ) {
        self.init(style: style, action: action) {
            Text(titleKey)
        }
    }
}

// MARK: - Label == AnyView

//public extension PQButton where Label == AnyView {
//
//    init(
//        _ titleKey: String,
//        icon: Image,
//        action: @escaping () -> Void
//    ) {
//        self.init(style: .init(.secondary, fullRounded: true), action: action) {
//            AnyView(
//                HStack(spacing: 8) {
//                    icon
//                        .renderingMode(.template)
//                        .foregroundStyle(PQColor.blue6.swiftUIColor)
//                    Text(titleKey)
//
//                    Spacer()
//
//                    Image(systemName: "chevron.right")
//                        .renderingMode(.template)
//                        .foregroundStyle(PQColor.base3.swiftUIColor)
//                }
//                .padding()
//            )
//        }
//    }
//
//    init(
//        _ titleKey: LocalizedStringKey,
//        icon: Image,
//        action: @escaping () -> Void
//    ) {
//        self.init(style: .init(.secondary, fullRounded: true), action: action) {
//            AnyView(
//                HStack(spacing: 8) {
//                    icon
//                        .renderingMode(.template)
//                        .foregroundStyle(PQColor.blue6.swiftUIColor)
//                    Text(titleKey)
//
//                    Spacer()
//
//                    Image(systemName: "chevron.right")
//                        .renderingMode(.template)
//                        .foregroundStyle(PQColor.base3.swiftUIColor)
//                }
//                .padding()
//            )
//        }
//    }
//}
