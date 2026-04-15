//
//  ImportContainerStatus.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 15.04.2026.
//

enum ImportContainerStatus: Equatable {
    case checkingFormat
    case checkingFingerprint
    case checkingAccess

    var text: String {
        switch self {
        case .checkingFormat:
            return "Проверяем формат файла..."
        case .checkingFingerprint:
            return "Проверяем подпись и fingerprint..."
        case .checkingAccess:
            return "Проверяем доступ..."
        }
    }
}
