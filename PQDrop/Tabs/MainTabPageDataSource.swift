//
//  MainTabPageDataSource.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 27.02.2026.
//

import SwiftUI
import PQUIComponents

struct MainTabPageDataSource {
    let page: MainTabPage

    var icon: Image {
        switch page {
        case .containers:
            PQImage.containers.swiftUIImage
        case .contacts:
            PQImage.contacts.swiftUIImage
        case .history:
            PQImage.history.swiftUIImage
        case .profile:
            PQImage.profile.swiftUIImage
        }
    }

    @ViewBuilder
    var title: some View {
        switch page {
        case .containers:
            Text("containers.title")
        case .contacts:
            Text("contacts.title")
        case .history:
            Text("history.title")
        case .profile:
            Text("profile.title")
        }
    }
}
