//
//  PQDropApp.swift
//  PQDrop
//
//  Created by Pavel Bobkov on 25.01.2026.
//

import SwiftUI

@main
struct PQDropApp: App {
    var body: some Scene {
        WindowGroup {
            SplashView(viewModel: .init())
        }
    }
}
