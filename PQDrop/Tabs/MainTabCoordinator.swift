//
//  MainTabCoordinator.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 27.02.2026.
//

import SUICoordinator

final class MainTabCoordinator: TabCoordinator<MainTabPage> {
    init() {
        super.init(
            pages: MainTabPage.allCases,
            currentPage: .containers,
            viewContainer: { MainTabView(dataSource: $0) }
        )
    }
}
