//
//  HistoryCoordinatorProtocol.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 15.04.2026.
//

protocol HistoryCoordinatorProtocol: AnyObject {
    func showHistoryFilterSheet(with model: HistoryFilterSheetModel) async
    func showHistoryEventDetails(with event: HistoryEvent) async
}
