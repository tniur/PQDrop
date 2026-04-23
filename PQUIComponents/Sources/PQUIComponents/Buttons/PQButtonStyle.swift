//
//  PQButtonStyle.swift
//  PQUIComponents
//
//  Created by Анастасия Журавлева on 16.02.2026.
//

import SwiftUI

public struct PQButtonStyle: ButtonStyle {

    // MARK: - Constants

    private enum Constant {
        static let cornerRadius = 28.0
    }

    // MARK: - Properties

    @Environment(\.isEnabled) private var isEnabled

    let type: PQButtonType
    private let isCompact: Bool
    private let height: CGFloat

    // MARK: - Initializer

    public init(
        _ type: PQButtonType,
        isCompact: Bool = false,
        height: CGFloat = 56.0
    ) {
        self.type = type
        self.isCompact = isCompact
        self.height = height
    }

    // MARK: - Methods

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(PQFont.R16)
            .frame(maxWidth: isCompact ? nil : .infinity)
            .frame(height: height)
            .padding(.horizontal, isCompact ? 20 : 16)
            .contentShape(RoundedRectangle(cornerRadius: Constant.cornerRadius))
            .foregroundStyle(isEnabled ? (configuration.isPressed ? type.pressedForegroundColor : type.foregroundColor) : type.disabledForegroundColor)
            .background {
                RoundedRectangle(cornerRadius: Constant.cornerRadius)
                    .fill(isEnabled ? (configuration.isPressed ? type.pressedBackgroundColor : type.backgroundColor) : type.disabledBackgroundColor)
            }
            .overlay {
                RoundedRectangle(cornerRadius: Constant.cornerRadius)
                    .stroke(isEnabled ? (configuration.isPressed ? type.pressedStrokeColor : type.strokeColor) : type.disabledStrokeColor, lineWidth: type.strokeWidth)
            }
    }
}
