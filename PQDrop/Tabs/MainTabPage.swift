//
//  MainTabPage.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 27.02.2026.
//

import SUICoordinator

enum MainTabPage: TabPage, CaseIterable {
    case containers
    case contacts
    case history
    case profile

    var position: Int {
        switch self {
        case .containers:
            return 0
        case .contacts:
            return 1
        case .history:
            return 2
        case .profile:
            return 3
        }
    }

    func coordinator() -> AnyCoordinatorType {
        switch self {
        case .containers:
            return ContainersCoordinator()
        case .contacts:
            return ContactsCoordinator()
        case .history:
            return ProfileCoordinator()
        case .profile:
            return ProfileCoordinator()
        }
    }

    var dataSource: MainTabPageDataSource {
        .init(page: self)
    }
}
