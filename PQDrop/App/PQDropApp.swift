//
//  PQDropApp.swift
//  PQDrop
//
//  Created by Pavel Bobkov on 25.01.2026.
//

import SwiftUI
import SUICoordinator

@main
struct PQDropApp: App {
    
    private let coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            coordinator.getView()
        }
    }
}
