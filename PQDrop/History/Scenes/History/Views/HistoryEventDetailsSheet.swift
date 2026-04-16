//
//  HistoryEventDetailsSheet.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 15.04.2026.
//

import SwiftUI
import PQUIComponents

struct HistoryEventDetailsSheet: View {

    // MARK: - Properties

    private let event: HistoryEvent

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(event.detailsTitle)
                .font(PQFont.B24)
                .foregroundStyle(PQColor.base10.swiftUIColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)

            VStack(alignment: .leading, spacing: 20) {
                detailsBlock(
                    title: "Дата и время",
                    value: event.dateTitle,
                    secondaryValue: event.time
                )

                detailsBlock(
                    title: "Контейнер",
                    value: event.containerName,
                    secondaryValue: "id: \(event.containerID)"
                )

                detailsBlock(
                    title: "Результат",
                    value: event.result
                )
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .presentationDetents([.height(280)])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Subviews

    @ViewBuilder
    private func detailsBlock(
        title: String,
        value: String,
        secondaryValue: String? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(PQFont.R12)
                .foregroundStyle(PQColor.base5.swiftUIColor)

            Text(value)
                .font(PQFont.B14)
                .foregroundStyle(PQColor.base10.swiftUIColor)

            if let secondaryValue {
                Text(secondaryValue)
                    .font(PQFont.R14)
                    .foregroundStyle(PQColor.blue6.swiftUIColor)
            }
        }
    }

    // MARK: - Initializer

    init(event: HistoryEvent) {
        self.event = event
    }
}
