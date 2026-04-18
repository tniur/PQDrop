//
//  RecipientRowView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 22.03.2026.
//

import SwiftUI
import PQUIComponents

struct RecipientRowView: View {

    // MARK: - Properties

    private let name: String
    private let shortKey: String
    private let isVerified: Bool

    // MARK: - Body

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(PQFont.B14)
                    .foregroundStyle(PQColor.base7.swiftUIColor)

                Text(shortKey)
                    .font(PQFont.R12)
                    .foregroundStyle(PQColor.base5.swiftUIColor)
            }

            Spacer()

            VerificationBadge(
                isVerified: isVerified,
                title: String(localized: isVerified ? "shared.status.verified" : "shared.status.unverified")
            )
        }
    }

    // MARK: - Initializer

    init(name: String, shortKey: String, isVerified: Bool) {
        self.name = name
        self.shortKey = shortKey
        self.isVerified = isVerified
    }
}
