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

// MARK: - Label == IconTextLabel

public extension PQButton where Label == IconTextLabel {

    init(
        _ titleKey: String,
        icon: Image,
        style: PQButtonStyle = .init(.primary, isCompact: false),
        action: @escaping () -> Void
    ) {
        self.init(style: style, action: action) {
            IconTextLabel(title: titleKey, icon: icon)
        }
    }

    init(
        _ titleKey: LocalizedStringKey,
        icon: Image,
        style: PQButtonStyle = .init(.primary, isCompact: false),
        action: @escaping () -> Void
    ) {
        self.init(style: style, action: action) {
            IconTextLabel(localizedTitle: titleKey, icon: icon)
        }
    }
}
