//
//  MainTabView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 27.02.2026.
//

import SwiftUI
import UIKit
import SUICoordinator
import PQUIComponents

struct MainTabView<DataSource: TabCoordinatorType>: View
where DataSource.Page == MainTabPage, DataSource.DataSourcePage == MainTabPageDataSource {
    
    // MARK: - Properties
    
    @StateObject private var dataSource: DataSource
    
    // MARK: - Initializer
    
    init(dataSource: DataSource) {
        _dataSource = .init(wrappedValue: dataSource)

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = PQColor.base10.color
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: PQColor.base10.color
        ]

        itemAppearance.selected.iconColor = PQColor.blue6.color
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: PQColor.blue6.color
        ]

        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.stackedLayoutAppearance = itemAppearance

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $dataSource.currentPage) {
            ForEach(dataSource.pages) { page in
                if let coordinator = dataSource.getCoordinator(with: page) {
                    coordinator.viewAsAnyView()
                        .tabItem {
                            Label(
                                title: {
                                    page.dataSource.title
                                },
                                icon: {
                                    page.dataSource.icon
                                        .renderingMode(.template)
                                }
                            )
                        }
                        .tag(page)
                }
            }
        }
    }
}
