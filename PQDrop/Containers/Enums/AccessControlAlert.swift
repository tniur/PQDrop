//
//  AccessControlAlert.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 31.03.2026.
//

enum AccessControlAlert: Identifiable {
    case applyAccessChanges
    case unverifiedWarning
    case operationFailed(message: String)
    
    var id: String {
        switch self {
        case .applyAccessChanges:
            return "applyAccessChanges"
        case .unverifiedWarning:
            return "unverifiedWarning"
        case .operationFailed(let message):
            return "operationFailed_\(message)"
        }
    }
}
