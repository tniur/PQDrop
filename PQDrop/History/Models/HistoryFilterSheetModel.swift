//
//  HistoryFilterSheetModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 15.04.2026.
//

struct HistoryFilterSheetModel {
    let currentFilter: HistoryEventFilter
    let onFilterChange: (HistoryEventFilter) -> Void
}
