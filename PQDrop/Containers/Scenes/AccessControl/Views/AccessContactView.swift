//
//  AccessContactView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 22.03.2026.
//

import SwiftUI
import PQUIComponents

struct AccessContactView: View {

    // MARK: - Properties

    private let name: String
    private let shortKey: String
    private let isVerified: Bool
    private let hasAccess: Bool
    private let isSelected: Bool

    // MARK: - Body

    var body: some View {
        HStack(spacing: 8) {
            titleView

            Spacer()

            VerificationBadge(
                isVerified: isVerified,
                title: String(localized: isVerified ? "shared.status.verified" : "shared.status.unverified")
            )

            PQImage.checkmarkCircle.swiftUIImage
                .renderingMode(.template)
                .foregroundStyle(
                    hasAccess
                    ? PQColor.blue7.swiftUIColor
                    : PQColor.base3.swiftUIColor
                )
        }
        .padding(20)
        .background(
            Capsule()
                .foregroundStyle(PQColor.base0.swiftUIColor)
        )
        .overlay(
            Capsule()
                .strokeBorder(
                    isSelected ? PQColor.blue7.swiftUIColor : PQColor.base0.swiftUIColor,
                    lineWidth: 2
                )
        )
    }

    // MARK: - Subviews

    private var titleView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name)
                .font(PQFont.B14)
                .foregroundStyle(PQColor.base10.swiftUIColor)

            Text(shortKey)
                .font(PQFont.R12)
                .foregroundStyle(PQColor.base5.swiftUIColor)
        }
    }

    // MARK: - Init

    init(
        name: String,
        shortKey: String,
        isVerified: Bool,
        hasAccess: Bool,
        isSelected: Bool
    ) {
        self.name = name
        self.shortKey = shortKey
        self.isVerified = isVerified
        self.hasAccess = hasAccess
        self.isSelected = isSelected
    }
}
