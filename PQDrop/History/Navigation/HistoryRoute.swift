//
//  HistoryRoute.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 15.04.2026.
//

import SwiftUI
import SUICoordinator

enum HistoryRoute: RouteType {
    case history(coordinator: HistoryCoordinatorProtocol)
    case historyFilterSheet(model: HistoryFilterSheetModel)
    case historyEventDetailsSheet(event: HistoryEvent)

    var presentationStyle: TransitionPresentationStyle {
        switch self {
        case .history:
            return .push
        case .historyFilterSheet, .historyEventDetailsSheet:
            return .sheet
        }
    }

    var body: some View {
        switch self {
        case .history(let coordinator):
            let viewModel = HistoryViewModel(coordinator: coordinator)
            let view = HistoryView(viewModel: viewModel)
            return AnyView(view)

        case .historyFilterSheet(let model):
            let view = HistoryFilterSheet(model: model)
            return AnyView(view)

        case .historyEventDetailsSheet(let event):
            let view = HistoryEventDetailsSheet(event: event)
            return AnyView(view)
        }
    }
}
