//
//  ContainerHistorySheetView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 16.04.2026.
//

import SwiftUI
import PQUIComponents

struct ContainerHistorySheetView: View {

    // MARK: - Properties

    private let events: [HistoryEvent]
    private let onShowAllTap: () -> Void

    private var latestDateTitle: String? {
        events.first?.dateTitle
    }

    private var latestDateEvents: [HistoryEvent] {
        guard let latestDateTitle else { return [] }
        return Array(events.filter { $0.dateTitle == latestDateTitle }.prefix(3))
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("История")
                .font(PQFont.B24)
                .foregroundStyle(PQColor.base10.swiftUIColor)
                .padding(.top, 20)

            if !events.isEmpty {
                emptyView
            } else {
                listView
            }
        }
        .padding(.horizontal, 20)
        .presentationDetents([.height(320)])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Subviews

    private var listView: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 16) {
                Text(latestDateTitle ?? "")
                    .font(PQFont.B16)
                    .foregroundStyle(PQColor.base10.swiftUIColor)
                
                VStack(spacing: 16) {
                    ForEach(latestDateEvents) { event in
                        eventRow(for: event)
                    }
                }
            }
            
            PQButton(
                "Смотреть все",
                style: .init(.purple),
                action: onShowAllTap
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var emptyView: some View {
        VStack(spacing: 8) {
            Spacer()

            Text("История пока пуста")
                .font(PQFont.B16)
                .foregroundStyle(PQColor.base5.swiftUIColor)

            Text("Здесь появятся действия с контейнером и доступом.")
                .font(PQFont.R12)
                .foregroundStyle(PQColor.base4.swiftUIColor)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func eventRow(for event: HistoryEvent) -> some View {
        HStack(spacing: 12) {
            event.icon.image
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(PQColor.base0.swiftUIColor)
                .frame(width: 20, height: 20)
                .padding(7)
                .background(
                    Circle()
                        .foregroundStyle(PQColor.blue6.swiftUIColor)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(event.listTitle)
                    .font(PQFont.B14)
                    .foregroundStyle(PQColor.base10.swiftUIColor)

                Text(event.time)
                    .font(PQFont.R12)
                    .foregroundStyle(PQColor.base5.swiftUIColor)
            }
        }
    }

    // MARK: - Initializer

    init(
        events: [HistoryEvent],
        onShowAllTap: @escaping () -> Void
    ) {
        self.events = events
        self.onShowAllTap = onShowAllTap
    }
}
