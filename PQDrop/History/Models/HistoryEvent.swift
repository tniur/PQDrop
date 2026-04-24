//
//  HistoryEvent.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 15.04.2026.
//

import SwiftUI
import PQUIComponents

enum HistoryEventType: String, CaseIterable {
    case created
    case export
    case imported
    case accessGranted
    case accessRevoked

    var filter: HistoryEventFilter {
        switch self {
        case .created, .export:
            return .export
        case .imported:
            return .imported
        case .accessGranted, .accessRevoked:
            return .access
        }
    }

    var icon: Image {
        switch self {
        case .created:
            return PQImage.plus.swiftUIImage
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

    var listTitlePrefix: String {
        switch self {
        case .created:
            return String(localized: "history.event.prefix.created")
        case .export:
            return String(localized: "history.event.prefix.export")
        case .imported:
            return String(localized: "history.event.prefix.imported")
        case .accessGranted, .accessRevoked:
            return String(localized: "history.event.prefix.access")
        }
    }

    var detailsTitle: String {
        switch self {
        case .created:
            return String(localized: "history.event.details.created")
        case .export:
            return String(localized: "history.event.details.export")
        case .imported:
            return String(localized: "history.event.details.imported")
        case .accessGranted, .accessRevoked:
            return String(localized: "history.event.details.access")
        }
    }

    var result: String {
        switch self {
        case .created, .export, .imported:
            return String(localized: "history.event.result.success")
        case .accessGranted:
            return String(localized: "history.event.result.access.granted")
        case .accessRevoked:
            return String(localized: "history.event.result.access.revoked")
        }
    }
}

struct HistoryEvent: Identifiable {
    let id: UUID
    let type: HistoryEventType
    let containerName: String
    let containerID: Data
    let detail: String?
    let timestamp: Date

    var containerIDHex: String {
        containerID.map { String(format: "%02x", $0) }.joined()
    }

    var icon: Image { type.icon }
    var detailsTitle: String { type.detailsTitle }
    var result: String { type.result }

    var listTitle: String {
        "\(type.listTitlePrefix) \"\(containerName)\""
    }

    var dateTitle: String {
        Self.dateTitleFormatter.string(from: timestamp)
    }

    var time: String {
        Self.timeFormatter.string(from: timestamp)
    }

    private static let dateTitleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

struct HistoryEventSection: Identifiable {
    let dateTitle: String
    let events: [HistoryEvent]

    var id: String { dateTitle }
}
