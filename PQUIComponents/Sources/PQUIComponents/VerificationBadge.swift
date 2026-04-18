//
//  VerificationBadge.swift
//  PQUIComponents
//
//  Created by Анастасия Журавлева on 22.03.2026.
//

import SwiftUI

public struct VerificationBadge: View {

    // MARK: - Properties

    private let isVerified: Bool
    private let title: String

    private var markIcon: Image {
        isVerified ? PQImage.done.swiftUIImage : PQImage.xmark.swiftUIImage
    }

    private var markBackgroundColor: Color {
        isVerified ? PQColor.green5.swiftUIColor : PQColor.base4.swiftUIColor
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: 2) {
            markIcon
                .renderingMode(.template)
                .foregroundStyle(PQColor.base0.swiftUIColor)

            Text(title)
                .font(PQFont.B12)
                .foregroundStyle(PQColor.base0.swiftUIColor)
        }
        .padding(8)
        .background(
            Capsule()
                .foregroundStyle(markBackgroundColor)
        )
    }

    // MARK: - Initializer

    public init(isVerified: Bool, title: String) {
        self.isVerified = isVerified
        self.title = title
    }
}
