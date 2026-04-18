//
//  ContainersTab.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 20.03.2026.
//

import Foundation

enum ContainersTab: Int, CaseIterable {
    case created = 0
    case received = 1

    var title: String {
        switch self {
        case .created:
            return String(localized: "containers.tab.created")
        case .received:
            return String(localized: "containers.tab.received")
        }
    }

    var emptyTitle: String {
        switch self {
        case .created:
            return String(localized: "containers.empty.created.title")
        case .received:
            return String(localized: "containers.empty.received.title")
        }
    }

    var emptySubtitle: String {
        switch self {
        case .created:
            return String(localized: "containers.empty.created.subtitle")
        case .received:
            return String(localized: "containers.empty.received.subtitle")
        }
    }

    var emptyButtonTitle: String {
        switch self {
        case .created:
            return String(localized: "shared.create")
        case .received:
            return String(localized: "shared.import")
        }
    }
}
