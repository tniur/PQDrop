//
//  CreateContainerStatus.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 13.04.2026.
//

enum CreateContainerStatus: Equatable {
    case preparingFiles
    case encrypting
    case savingContainer

    var text: String {
        switch self {
        case .preparingFiles:
            return "Подготавливаем файлы..."
        case .encrypting:
            return "Шифруем содержимое..."
        case .savingContainer:
            return "Сохраняем контейнер..."
        }
    }
}
