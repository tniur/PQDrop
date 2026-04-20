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
        "Логи хранятся \(selectedRetentionPeriod.title)"
    }

    var retentionAlertMessage: String {
        guard let pendingRetentionPeriod else {
            return ""
        }

        if pendingRetentionPeriod.rawValue < selectedRetentionPeriod.rawValue {
            return "При сокращении срока хранения будет сложнее отслеживать действия"
        }

        return "История будет храниться \(pendingRetentionPeriod.title)."
    }

    var visibleSections: [HistoryEventSection] {
        sections.compactMap { section in
            let events = filteredEvents(from: section.events)
            guard !events.isEmpty else { return nil }
            return HistoryEventSection(dateTitle: section.dateTitle, events: events)
        }
    }

    private let coordinator: HistoryCoordinatorProtocol

    private var sections: [HistoryEventSection] {
        let calendar = Calendar.current
        let march20 = calendar.date(from: DateComponents(year: 2026, month: 3, day: 20))!
        let march19 = calendar.date(from: DateComponents(year: 2026, month: 3, day: 19))!
        let march17 = calendar.date(from: DateComponents(year: 2026, month: 3, day: 17))!
        let containerID = Data(repeating: 0, count: 16)

        let events20: [HistoryEvent] = [
            .init(id: UUID(), type: .export, containerName: "Название контейнера", containerID: containerID, detail: nil,
                  timestamp: calendar.date(bySettingHour: 12, minute: 9, second: 0, of: march20)!),
            .init(id: UUID(), type: .imported, containerName: "Название контейнера", containerID: containerID, detail: nil,
                  timestamp: calendar.date(bySettingHour: 11, minute: 11, second: 0, of: march20)!),
            .init(id: UUID(), type: .accessGranted, containerName: "Название контейнера", containerID: containerID, detail: nil,
                  timestamp: calendar.date(bySettingHour: 10, minute: 12, second: 0, of: march20)!),
            .init(id: UUID(), type: .accessRevoked, containerName: "Название контейнера", containerID: containerID, detail: nil,
                  timestamp: calendar.date(bySettingHour: 9, minute: 56, second: 0, of: march20)!)
        ]

        let events19: [HistoryEvent] = [
            .init(id: UUID(), type: .export, containerName: "Название контейнера", containerID: containerID, detail: nil,
                  timestamp: calendar.date(bySettingHour: 10, minute: 12, second: 0, of: march19)!),
            .init(id: UUID(), type: .imported, containerName: "Название контейнера", containerID: containerID, detail: nil,
                  timestamp: calendar.date(bySettingHour: 10, minute: 10, second: 0, of: march19)!),
            .init(id: UUID(), type: .accessGranted, containerName: "Название контейнера", containerID: containerID, detail: nil,
                  timestamp: calendar.date(bySettingHour: 10, minute: 3, second: 0, of: march19)!),
            .init(id: UUID(), type: .accessRevoked, containerName: "Название контейнера", containerID: containerID, detail: nil,
                  timestamp: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: march19)!)
        ]

        let events17: [HistoryEvent] = [
            .init(id: UUID(), type: .export, containerName: "Название контейнера", containerID: containerID, detail: nil,
                  timestamp: calendar.date(bySettingHour: 11, minute: 48, second: 0, of: march17)!),
            .init(id: UUID(), type: .accessGranted, containerName: "Название контейнера", containerID: containerID, detail: nil,
                  timestamp: calendar.date(bySettingHour: 10, minute: 55, second: 0, of: march17)!)
        ]

        return [
            HistoryEventSection(dateTitle: events20.first!.dateTitle, events: events20),
            HistoryEventSection(dateTitle: events19.first!.dateTitle, events: events19),
            HistoryEventSection(dateTitle: events17.first!.dateTitle, events: events17)
        ]
    }

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
