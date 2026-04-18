//
//  ImportContainerStatus.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 15.04.2026.
//

import Foundation

enum ImportContainerStatus: Equatable {
    case checkingFormat
    case checkingFingerprint
    case checkingAccess

    var text: String {
        switch self {
        case .checkingFormat:
            return String(localized: "containers.import.status.checking.format")
        case .checkingFingerprint:
            return String(localized: "containers.import.status.checking.fingerprint")
        case .checkingAccess:
            return String(localized: "containers.import.status.checking.access")
        }
    }
}
