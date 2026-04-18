//
//  SaveContainerStatus.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 12.04.2026.
//

import Foundation

enum SaveContainerStatus: Equatable {
    case preparingFiles
    case updatingContainer
    case reEncrypting

    var text: String {
        switch self {
        case .preparingFiles:
            return String(localized: "containers.save.status.preparing.files")
        case .updatingContainer:
            return String(localized: "containers.save.status.updating")
        case .reEncrypting:
            return String(localized: "containers.save.status.reencrypting")
        }
    }
}
