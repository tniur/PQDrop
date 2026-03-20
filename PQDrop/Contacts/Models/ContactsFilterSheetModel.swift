//
//  ContactsFilterSheetModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 01.03.2026.
//

struct ContactsFilterSheetModel {
    let currentFilter: ContactsFilter
    let onFilterChange: (ContactsFilter) -> Void
}
