//
//  SaveContainerStatus.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 12.04.2026.
//

enum SaveContainerStatus: Equatable {
    case preparingFiles
    case updatingContainer
    case reEncrypting

    var text: String {
        switch self {
        case .preparingFiles:
            return "Подготавливаем файлы..."
        case .updatingContainer:
            return "Обновляем контейнер..."
        case .reEncrypting:
            return "Перешифровываем содержимое..."
        }
    }
}
