//
//  HistoryCoordinator.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 15.04.2026.
//

import SUICoordinator

@MainActor
final class HistoryCoordinator: Coordinator<HistoryRoute>, HistoryCoordinatorProtocol {

    override init() {
        super.init()
        Task { [weak self] in
            await self?.start()
        }
    }

    override func start() async {
        await startFlow(route: .history(coordinator: self))
    }

    func showHistoryFilterSheet(with model: HistoryFilterSheetModel) async {
        await navigate(toRoute: .historyFilterSheet(model: model))
    }

    func showHistoryEventDetails(with event: HistoryEvent) async {
        await navigate(toRoute: .historyEventDetailsSheet(event: event))
    }
}
