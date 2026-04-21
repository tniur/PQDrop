//
//  CreateKeysViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлеva on 19.02.2026.
//

import Combine
import Foundation
import PQContainerKit

@MainActor
final class CreateKeysViewModel: ObservableObject {

    // MARK: - Enums

    enum Phase: Equatable {
        case idle
        case creating
        case success
        case failure
    }

    // MARK: - Properties

    @Published var phase: Phase = .idle
    @Published var progress: Double = 0
    @Published var status: CreateKeysStatus = .generating

    private var uiTask: Task<Void, Never>?
    private var workTask: Task<Void, Never>?
    
    private let coordinator: OnboardingCoordinatorProtocol
    private let keyPairManager: KeyPairManager

    // MARK: - Initializer

    init(coordinator: OnboardingCoordinatorProtocol, keyPairManager: KeyPairManager) {
        self.coordinator = coordinator
        self.keyPairManager = keyPairManager
    }
    
    // MARK: - Methods

    func createKeys() {
        cancel()

        phase = .creating
        progress = 0
        status = .generating

        uiTask = Task { [weak self] in
            guard let self else { return }

            let tick: Double = 0.05
            let fillDuration: Double = 4.0
            let steps = Int(fillDuration / tick)

            for i in 0...steps {
                if Task.isCancelled { return }

                let t = Double(i) * tick
                self.progress = min(1, t / fillDuration)

                if t < 2.0 { self.status = .generating }
                else { self.status = .saving }

                if i < steps {
                    try? await Task.sleep(nanoseconds: UInt64(tick * 1_000_000_000))
                }
            }

            self.progress = 1
            self.status = .slowDeviceHint
        }

        workTask = Task { [weak self] in
            guard let self else { return }

            let result = await Task.detached(priority: .userInitiated) { [keyPairManager = self.keyPairManager] in
                Result { try keyPairManager.generateAndStore() }
            }.value

            if Task.isCancelled { return }

            await self.uiTask?.value

            if Task.isCancelled { return }

            self.progress = 1

            switch result {
            case .success:
                self.phase = .success
            case .failure:
                self.phase = .failure
            }
        }
    }

    func retry() {
        createKeys()
    }

    func cancel() {
        uiTask?.cancel()
        workTask?.cancel()
        uiTask = nil
        workTask = nil
    }
    
    func finish() {
        Task {
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.onboardingCompleted)
            await coordinator.restartSplash()
        }
    }

    deinit {
        uiTask?.cancel()
        workTask?.cancel()
    }
}
