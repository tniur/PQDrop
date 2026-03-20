//
//  ContainersTab.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 20.03.2026.
//

enum ContainersTab: Int, CaseIterable {
    case created = 0
    case received = 1

    var title: String {
        switch self {
        case .created:
            return "Созданные"
        case .received:
            return "Полученные"
        }
    }

    var emptyTitle: String {
        switch self {
        case .created:
            return "У вас пока\nнет контейнеров"
        case .received:
            return "Пока нет полученных\nконтейнеров"
        }
    }

    var emptySubtitle: String {
        switch self {
        case .created:
            return "Создайте контейнер, чтобы зашифровать файлы и выдать доступ получателям."
        case .received:
            return "Импортируйте контейнер из Files или получите его другим способом."
        }
    }

    var emptyButtonTitle: String {
        switch self {
        case .created:
            return "Создать"
        case .received:
            return "Импортировать"
        }
    }
}
