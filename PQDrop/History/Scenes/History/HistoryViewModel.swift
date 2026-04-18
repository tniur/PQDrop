//
//  HistoryViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 15.04.2026.
//

import Combine
import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {

    // MARK: - Properties

    @Published var selectedRetentionPeriod: HistoryRetentionPeriod = .ninety
    @Published var pendingRetentionPeriod: HistoryRetentionPeriod?
    @Published var showRetentionAlert = false
    @Published var filter: HistoryEventFilter = .all

    var retentionSubtitle: String {
        String(localized: "history.retention.subtitle\(selectedRetentionPeriod.title)")
    }

    var retentionAlertMessage: String {
        guard let pendingRetentionPeriod else {
            return ""
        }

        if pendingRetentionPeriod.rawValue < selectedRetentionPeriod.rawValue {
            return String(localized: "history.retention.alert.message.decrease")
        }

        return String(localized: "history.retention.alert.message.increase\(pendingRetentionPeriod.title)")
    }

    var visibleSections: [HistoryEventSection] {
        sections.compactMap { section in
            let events = filteredEvents(from: section.events)
            guard !events.isEmpty else { return nil }
            return HistoryEventSection(dateTitle: section.dateTitle, events: events)
        }
    }

    private let coordinator: HistoryCoordinatorProtocol
    private let sections: [HistoryEventSection] = [
        .init(
            dateTitle: "20 марта 2026",
            events: [
                .init(
                    id: "export-20-1209",
                    type: .export,
                    icon: .export,
                    listTitle: "Экспорт \"Название контейнера\"",
                    detailsTitle: "Экспорт контейнера",
                    dateTitle: "20 марта 2026",
                    time: "12:09",
                    containerName: "Название контейнера",
                    containerID: "999999999",
                    result: "Успешно"
                ),
                .init(
                    id: "import-20-1111",
                    type: .imported,
                    icon: .imported,
                    listTitle: "Импорт \"Название контейнера\"",
                    detailsTitle: "Импорт контейнера",
                    dateTitle: "20 марта 2026",
                    time: "11:11",
                    containerName: "Название контейнера",
                    containerID: "999999999",
                    result: "Успешно"
                ),
                .init(
                    id: "access-20-1012",
                    type: .access,
                    icon: .accessGranted,
                    listTitle: "Доступ \"Название контейнера\"",
                    detailsTitle: "Доступ контейнера",
                    dateTitle: "20 марта 2026",
                    time: "10:12",
                    containerName: "Название контейнера",
                    containerID: "999999999",
                    result: "Доступ выдан"
                ),
                .init(
                    id: "access-20-0956",
                    type: .access,
                    icon: .accessRevoked,
                    listTitle: "Доступ \"Название контейнера\"",
                    detailsTitle: "Доступ контейнера",
                    dateTitle: "20 марта 2026",
                    time: "09:56",
                    containerName: "Название контейнера",
                    containerID: "999999999",
                    result: "Доступ закрыт"
                )
            ]
        ),
        .init(
            dateTitle: "19 марта 2026",
            events: [
                .init(
                    id: "export-19-1012",
                    type: .export,
                    icon: .export,
                    listTitle: "Экспорт \"Название контейнера\"",
                    detailsTitle: "Экспорт контейнера",
                    dateTitle: "19 марта 2026",
                    time: "10:12",
                    containerName: "Название контейнера",
                    containerID: "999999999",
                    result: "Успешно"
                ),
                .init(
                    id: "import-19-1010",
                    type: .imported,
                    icon: .imported,
                    listTitle: "Импорт \"Название контейнера\"",
                    detailsTitle: "Импорт контейнера",
                    dateTitle: "19 марта 2026",
                    time: "10:10",
                    containerName: "Название контейнера",
                    containerID: "999999999",
                    result: "Успешно"
                ),
                .init(
                    id: "access-19-1003",
                    type: .access,
                    icon: .accessGranted,
                    listTitle: "Доступ \"Название контейнера\"",
                    detailsTitle: "Доступ контейнера",
                    dateTitle: "19 марта 2026",
                    time: "10:03",
                    containerName: "Название контейнера",
                    containerID: "999999999",
                    result: "Доступ выдан"
                ),
                .init(
                    id: "access-19-1000",
                    type: .access,
                    icon: .accessRevoked,
                    listTitle: "Доступ \"Название контейнера\"",
                    detailsTitle: "Доступ контейнера",
                    dateTitle: "19 марта 2026",
                    time: "10:00",
                    containerName: "Название контейнера",
                    containerID: "999999999",
                    result: "Доступ закрыт"
                )
            ]
        ),
        .init(
            dateTitle: "17 марта 2026",
            events: [
                .init(
                    id: "export-17-1148",
                    type: .export,
                    icon: .export,
                    listTitle: "Экспорт \"Название контейнера\"",
                    detailsTitle: "Экспорт контейнера",
                    dateTitle: "17 марта 2026",
                    time: "11:48",
                    containerName: "Название контейнера",
                    containerID: "999999999",
                    result: "Успешно"
                ),
                .init(
                    id: "access-17-1055",
                    type: .access,
                    icon: .accessGranted,
                    listTitle: "Доступ \"Название контейнера\"",
                    detailsTitle: "Доступ контейнера",
                    dateTitle: "17 марта 2026",
                    time: "10:55",
                    containerName: "Название контейнера",
                    containerID: "999999999",
                    result: "Доступ выдан"
                )
            ]
        )
    ]

    // MARK: - Initializer

    init(coordinator: HistoryCoordinatorProtocol) {
        self.coordinator = coordinator
    }

    // MARK: - Methods

    func requestRetentionChange(to period: HistoryRetentionPeriod) {
        guard period != selectedRetentionPeriod else { return }
        pendingRetentionPeriod = period
        showRetentionAlert = true
    }

    func confirmRetentionChange() {
        guard let pendingRetentionPeriod else { return }
        selectedRetentionPeriod = pendingRetentionPeriod
        self.pendingRetentionPeriod = nil
    }

    func cancelRetentionChange() {
        pendingRetentionPeriod = nil
    }

    func showFilters() {
        Task {
            let model = HistoryFilterSheetModel(currentFilter: filter) { filter in
                self.filter = filter
            }
            await coordinator.showHistoryFilterSheet(with: model)
        }
    }

    func showDetails(of event: HistoryEvent) {
        Task {
            await coordinator.showHistoryEventDetails(with: event)
        }
    }

    private func filteredEvents(from events: [HistoryEvent]) -> [HistoryEvent] {
        guard filter != .all else { return events }
        return events.filter { $0.type.filter == filter }
    }
}
