//
//  ContactsFilter.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 01.03.2026.
//

enum ContactsFilter: String, CaseIterable, Identifiable {
    case all = "Все"
    case verifiedOnly = "Только верифицированные"
    case unverifiedOnly = "Только неверифицированные"
    
    var id: Self { self }
}
