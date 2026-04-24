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
    @Published private(set) var sections: [HistoryEventSection] = []

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

    private let coordinator: HistoryCoordinatorProtocol
    private let historyRepository: HistoryRepository

    init(coordinator: HistoryCoordinatorProtocol, historyRepository: HistoryRepository) {
        self.coordinator = coordinator
        self.historyRepository = historyRepository

        let savedDays = UserDefaults.standard.integer(forKey: UserDefaultsKeys.historyRetentionDays)
        if let period = HistoryRetentionPeriod(rawValue: savedDays) {
            self.selectedRetentionPeriod = period
        }

        loadData()
    }

    func loadData() {
        let events = historyRepository.fetchAll(
            filter: filter,
            retentionDays: selectedRetentionPeriod.rawValue
        )
        sections = historyRepository.groupBySections(events)
    }

    // MARK: - Methods

    func requestRetentionChange(to period: HistoryRetentionPeriod) {
        guard period != selectedRetentionPeriod else { return }
        pendingRetentionPeriod = period
        showRetentionAlert = true
    }

    func confirmRetentionChange() {
        guard let pendingRetentionPeriod else { return }
        let previousPeriod = selectedRetentionPeriod
        selectedRetentionPeriod = pendingRetentionPeriod
        self.pendingRetentionPeriod = nil

        UserDefaults.standard.set(selectedRetentionPeriod.rawValue, forKey: UserDefaultsKeys.historyRetentionDays)

        if selectedRetentionPeriod.rawValue < previousPeriod.rawValue {
            try? historyRepository.deleteOlderThan(days: selectedRetentionPeriod.rawValue)
        }

        loadData()
    }

    func cancelRetentionChange() {
        pendingRetentionPeriod = nil
    }

    func showFilters() {
        Task {
            let model = HistoryFilterSheetModel(currentFilter: filter) { filter in
                self.filter = filter
                self.loadData()
            }
            await coordinator.showHistoryFilterSheet(with: model)
        }
    }

    func showDetails(of event: HistoryEvent) {
        Task {
            await coordinator.showHistoryEventDetails(with: event)
        }
    }

}
