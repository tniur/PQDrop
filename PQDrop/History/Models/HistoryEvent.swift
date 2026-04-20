//
//  HistoryEvent.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 15.04.2026.
//

import SwiftUI
import PQUIComponents

enum HistoryEventType: String, CaseIterable {
    case export
    case imported
    case accessGranted
    case accessRevoked

    var filter: HistoryEventFilter {
        switch self {
        case .export:
            return .export
        case .imported:
            return .imported
        case .accessGranted, .accessRevoked:
            return .access
        }
    }

    var icon: Image {
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

    var listTitlePrefix: String {
        switch self {
        case .export:
            return "Экспорт"
        case .imported:
            return "Импорт"
        case .accessGranted, .accessRevoked:
            return "Доступ"
        }
    }

    var detailsTitle: String {
        switch self {
        case .export:
            return "Экспорт контейнера"
        case .imported:
            return "Импорт контейнера"
        case .accessGranted, .accessRevoked:
            return "Доступ контейнера"
        }
    }

    var result: String {
        switch self {
        case .export, .imported:
            return "Успешно"
        case .accessGranted:
            return "Доступ выдан"
        case .accessRevoked:
            return "Доступ закрыт"
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
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

struct HistoryEventSection: Identifiable {
    let dateTitle: String
    let events: [HistoryEvent]

    var id: String { dateTitle }
}
