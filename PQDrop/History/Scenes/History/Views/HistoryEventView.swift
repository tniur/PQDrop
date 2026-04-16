//
//  HistoryEventView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 15.04.2026.
//

import SwiftUI
import PQUIComponents

struct HistoryEventView: View {

    // MARK: - Properties

    private let event: HistoryEvent

    // MARK: - Body

    var body: some View {
        HStack(spacing: 6) {
            iconView

            VStack(alignment: .leading, spacing: 2) {
                Text(event.listTitle)
                    .font(PQFont.B14)
                    .foregroundStyle(PQColor.base0.swiftUIColor)
                    .lineLimit(1)

                Text(event.time)
                    .font(PQFont.R12)
                    .foregroundStyle(PQColor.blue2.swiftUIColor)
            }

            Spacer(minLength: 4)

            PQImage.chevronForward.swiftUIImage
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(PQColor.base0.swiftUIColor)
                .frame(width: 20, height: 20)
        }
        .contentShape(Rectangle())
    }

    // MARK: - Subviews

    private var iconView: some View {
        event.icon.image
            .resizable()
            .renderingMode(.template)
            .foregroundStyle(PQColor.base10.swiftUIColor)
            .frame(width: 20, height: 20)
            .padding(7)
            .background(
                Circle()
                    .foregroundStyle(PQColor.base0.swiftUIColor)
            )
    }

    // MARK: - Initializer

    init(event: HistoryEvent) {
        self.event = event
    }
}
