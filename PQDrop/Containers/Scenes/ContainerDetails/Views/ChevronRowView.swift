//
//  ChevronRowView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 22.03.2026.
//

import SwiftUI
import PQUIComponents

struct ChevronRowView: View {

    // MARK: - Properties

    private let icon: Image
    private let title: String
    private let isEnabled: Bool

    private var iconColor: Color {
        isEnabled ? PQColor.blue6.swiftUIColor : PQColor.blue4.swiftUIColor
    }

    private var titleColor: Color {
        isEnabled ? PQColor.base10.swiftUIColor : PQColor.base4.swiftUIColor
    }

    private var chevronColor: Color {
        isEnabled ? PQColor.base10.swiftUIColor : PQColor.base4.swiftUIColor
    }
    
    private var backgroundColor: Color {
        isEnabled ? PQColor.base0.swiftUIColor : PQColor.base1.swiftUIColor
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 8) {
            icon
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(iconColor)
                .frame(width: 24, height: 24)

            Text(title)
                .font(PQFont.R16)
                .foregroundStyle(titleColor)

            Spacer()

            PQImage.chevronForward.swiftUIImage
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(chevronColor)
                .frame(width: 24, height: 24)
        }
        .padding()
        .background(
            Capsule()
                .foregroundStyle(backgroundColor)
        )
    }

    // MARK: - Initializer

    init(icon: Image, title: String, isEnabled: Bool = true) {
        self.icon = icon
        self.title = title
        self.isEnabled = isEnabled
    }
}
