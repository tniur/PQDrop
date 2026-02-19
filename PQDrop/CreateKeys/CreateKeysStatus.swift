//
//  CreateKeysStatus.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 19.02.2026.
//

enum CreateKeysStatus: Equatable {
    case generating
    case saving
    case slowDeviceHint

    var text: String {
        switch self {
        case .generating: return "Генерируем ключи..."
        case .saving: return "Сохраняем в защищённое хранилище…"
        case .slowDeviceHint: return "На некоторых устройствах это может занять немного больше времени."
        }
    }
}
