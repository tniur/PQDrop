//
//  AccessControlAlert.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 31.03.2026.
//

enum AccessControlAlert: Identifiable {
        case noSelection
        case applyAccessChanges
        case revokeAccess(contactId: String)

        var id: String {
            switch self {
            case .noSelection:
                return "noSelection"
            case .applyAccessChanges:
                return "applyAccessChanges"
            case .revokeAccess(let contactId):
                return "revokeAccess_\(contactId)"
            }
        }
    }
