//
//  AppCoordinatorProtocol.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 25.02.2026.
//

protocol AppCoordinatorProtocol: AnyObject {
    func showOnboarding() async
    func showMainTabs() async
    func restartSplash() async
}
