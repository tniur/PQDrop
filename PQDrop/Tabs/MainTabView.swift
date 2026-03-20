//
//  MainTabView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 27.02.2026.
//

import SwiftUI
import SUICoordinator

struct MainTabView<DataSource: TabCoordinatorType>: View
where DataSource.Page == MainTabPage, DataSource.DataSourcePage == MainTabPageDataSource {

    // MARK: - Properties

    @StateObject private var dataSource: DataSource

    // MARK: - Initializer

    init(dataSource: DataSource) {
        _dataSource = .init(wrappedValue: dataSource)
    }

    // MARK: - Body

    var body: some View {
        TabView(selection: $dataSource.currentPage) {
            ForEach(dataSource.pages) { page in
                if let coordinator = dataSource.getCoordinator(with: page) {
                    coordinator.viewAsAnyView()
                        .tabItem {
                            Label(title: { page.dataSource.title },
                                  icon: { page.dataSource.icon })
                        }
                        .tag(page)
                }
            }
        }
    }
}
