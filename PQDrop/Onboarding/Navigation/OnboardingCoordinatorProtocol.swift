//
//  OnboardingCoordinatorProtocol.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 25.02.2026.
//

protocol OnboardingCoordinatorProtocol: AnyObject {
    func showCreateKeys() async
    func restartSplash() async
}
