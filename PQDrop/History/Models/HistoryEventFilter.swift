//
//  HistoryEventFilter.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 15.04.2026.
//

import Foundation

enum HistoryEventFilter: CaseIterable, Identifiable {
    case all
    case export
    case imported
    case access

    var id: Self { self }

    var title: String {
        switch self {
        case .all:
            return String(localized: "history.filter.all.events")
        case .export:
            return String(localized: "history.filter.export")
        case .imported:
            return String(localized: "history.filter.import")
        case .access:
            return String(localized: "history.filter.access")
        }
    }
}
