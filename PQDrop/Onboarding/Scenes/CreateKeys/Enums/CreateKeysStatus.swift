//
//  CreateKeysStatus.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 19.02.2026.
//

import Foundation

enum CreateKeysStatus: Equatable {
    case generating
    case saving
    case slowDeviceHint

    var text: String {
        switch self {
        case .generating:
            return String(localized: "onboarding.keys.status.generating")
        case .saving: 
            return String(localized: "onboarding.keys.status.saving")
        case .slowDeviceHint: 
            return String(localized: "onboarding.keys.status.slow.device")
        }
    }
}
