//
//  HistoryEventFilter.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 15.04.2026.
//

enum HistoryEventFilter: String, CaseIterable, Identifiable {
    case all = "Все события"
    case export = "Экспорт"
    case imported = "Импорт"
    case access = "Доступ"

    var id: String { rawValue }
}
