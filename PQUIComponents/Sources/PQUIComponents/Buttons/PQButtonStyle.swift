//
//  PQButtonStyle.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 16.02.2026.
//

import SwiftUI

public struct PQButtonStyle: ButtonStyle {

    // MARK: - Constants

    private enum Constant {
        static let cornerRadius = 28.0
        static let height = 56.0
    }

    // MARK: - Properties

    private let type: PQButtonType
    @Environment(\.isEnabled)
    private var isEnabled

    // MARK: - Initializer

    public init(_ type: PQButtonType) {
        self.type = type
    }

    // MARK: - Methods

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(PQFont.R16)
            .frame(maxWidth: .infinity)
            .frame(height: Constant.height)
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
