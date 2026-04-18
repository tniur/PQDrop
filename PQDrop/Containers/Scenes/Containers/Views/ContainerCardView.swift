//
//  ContainerCardView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 20.03.2026.
//

import SwiftUI
import PQUIComponents

struct ContainerCardView: View {

    // MARK: - Properties

    private let name: String
    private let id: String
    private let isAvailable: Bool

    private var boxColor: Color {
        isAvailable ? PQColor.blue6.swiftUIColor : PQColor.base4.swiftUIColor
    }

    private var nameColor: Color {
        isAvailable ? PQColor.base10.swiftUIColor : PQColor.base5.swiftUIColor
    }

    private var idColor: Color {
        isAvailable ? PQColor.base5.swiftUIColor : PQColor.base3.swiftUIColor
    }

    private var chevronColor: Color {
        isAvailable ? PQColor.base10.swiftUIColor : PQColor.base4.swiftUIColor
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 8) {
            PQImage.box.swiftUIImage
                .renderingMode(.template)
                .foregroundStyle(boxColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(PQFont.B16)
                    .foregroundStyle(nameColor)

                Text(String(localized: "shared.id\(id)"))
                    .font(PQFont.R12)
                    .foregroundStyle(idColor)
            }

            Spacer()

            PQImage.chevronForward.swiftUIImage
                .renderingMode(.template)
                .foregroundStyle(chevronColor)
        }
        .padding(20)
        .background(
            Capsule()
                .foregroundStyle(PQColor.base0.swiftUIColor)
        )
    }

    // MARK: - Initializer

    init(name: String, id: String, isAvailable: Bool) {
        self.name = name
        self.id = id
        self.isAvailable = isAvailable
    }
}
