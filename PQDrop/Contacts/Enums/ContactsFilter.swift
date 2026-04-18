//
//  ContactsFilter.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 01.03.2026.
//

import Foundation

enum ContactsFilter: CaseIterable, Identifiable {
    case all
    case verifiedOnly
    case unverifiedOnly

    var id: Self { self }

    var title: String {
        switch self {
        case .all:
            return String(localized: "contacts.filter.all")
        case .verifiedOnly:
            return String(localized: "contacts.filter.verified.only")
        case .unverifiedOnly:
            return String(localized: "contacts.filter.unverified.only")
        }
    }
}
