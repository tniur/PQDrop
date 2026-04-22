//
//  AccessControlAlert.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 31.03.2026.
//

enum AccessControlAlert: Identifiable {
    case noSelection
    case applyAccessChanges
    case unverifiedWarning
    case revokeAccess(contactId: String)
    case operationFailed(message: String)
    
    var id: String {
        switch self {
        case .noSelection:
            return "noSelection"
        case .applyAccessChanges:
            return "applyAccessChanges"
        case .unverifiedWarning:
            return "unverifiedWarning"
        case .revokeAccess(let contactId):
            return "revokeAccess_\(contactId)"
        case .operationFailed(let message):
            return "operationFailed_\(message)"
        }
    }
}
