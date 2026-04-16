//
//  HistoryEvent.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 15.04.2026.
//

import SwiftUI
import PQUIComponents

enum HistoryEventType {
    case export
    case imported
    case access

    var filter: HistoryEventFilter {
        switch self {
        case .export:
            return .export
        case .imported:
            return .imported
        case .access:
            return .access
        }
    }
}

enum HistoryEventIcon {
    case export
    case imported
    case accessGranted
    case accessRevoked

    var image: Image {
        switch self {
        case .export:
            return PQImage.export.swiftUIImage
        case .imported:
            return PQImage.import.swiftUIImage
        case .accessGranted:
            return PQImage.done.swiftUIImage
        case .accessRevoked:
            return PQImage.xmark.swiftUIImage
        }
    }
}

struct HistoryEvent: Identifiable {
    let id: String
    let type: HistoryEventType
    let icon: HistoryEventIcon
    let listTitle: String
    let detailsTitle: String
    let dateTitle: String
    let time: String
    let containerName: String
    let containerID: String
    let result: String
}

struct HistoryEventSection: Identifiable {
    let dateTitle: String
    let events: [HistoryEvent]

    var id: String { dateTitle }
}
