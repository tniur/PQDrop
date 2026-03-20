//
//  PQTextField.swift
//  PQUIComponents
//
//  Created by Анастасия Журавлева on 01.03.2026.
//

import SwiftUI

public struct PQTextField: View {

    // MARK: - Properties

    @Binding var text: String

    @FocusState private var isFocused: Bool

    private let placeholderText: String

    // MARK: - Body

    public var body: some View {
        TextField(placeholderText, text: $text)
            .focused($isFocused)
            .font(PQFont.R14)
            .foregroundStyle(
                isFocused || !text.isEmpty ? PQColor.base10.swiftUIColor : PQColor.base3.swiftUIColor
            )
            .frame(height: 18)
            .padding()
            .background {
                Capsule()
                    .fill(PQColor.base0.swiftUIColor)
            }
            .onTapGesture {
                isFocused = true
            }
    }

    // MARK: - Initializer

    public init(
        placeholderText: String,
        text: Binding<String>
    ) {
        self.placeholderText = placeholderText
        self._text = text
    }
}
