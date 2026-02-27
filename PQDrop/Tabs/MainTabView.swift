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

    @StateObject var dataSource: DataSource

    init(dataSource: DataSource) {
        _dataSource = .init(wrappedValue: dataSource)
    }

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
