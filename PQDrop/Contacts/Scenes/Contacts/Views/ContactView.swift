//
//  ContactView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 28.02.2026.
//

import SwiftUI
import PQUIComponents

struct ContactView: View {
    
    // MARK: - Properties

    private let name: String
    private let isVerified: Bool

    // MARK: - Body

    var body: some View {
        HStack {
            Text(name)
                .font(PQFont.B14)
                .foregroundStyle(PQColor.base10.swiftUIColor)

            Spacer()

            VerificationBadge(isVerified: isVerified)
        }
        .padding(.vertical)
        .padding(.horizontal, 20)
        .background(
            Capsule()
                .foregroundStyle(PQColor.base0.swiftUIColor)
        )
    }
    
    // MARK: - Initializer

    init(name: String, isVerified: Bool) {
        self.name = name
        self.isVerified = isVerified
    }
}
