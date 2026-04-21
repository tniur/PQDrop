//
//  CreateContainerStatus.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 13.04.2026.
//

import Foundation

enum CreateContainerStatus: Equatable {
    case preparingFiles
    case encrypting
    case savingContainer

    var text: String {
        switch self {
        case .preparingFiles:
            return String(localized: "containers.create.status.preparing.files")
        case .encrypting:
            return String(localized: "containers.create.status.encrypting")
        case .savingContainer:
            return String(localized: "containers.create.status.saving")
        }
    }
}
