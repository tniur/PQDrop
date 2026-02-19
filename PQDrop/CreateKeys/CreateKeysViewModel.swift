//
//  CreateKeysViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлеva on 19.02.2026.
//

import Combine
import Foundation

@MainActor
final class CreateKeysViewModel: ObservableObject {

    enum Phase: Equatable {
        case idle
        case creating
        case success
        case failure
    }

    @Published var phase: Phase = .idle
    @Published var progress: Double = 0
    @Published var status: CreateKeysStatus = .generating

    private var uiTask: Task<Void, Never>?
    private var workTask: Task<Void, Never>?

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

            // тут позже будет реальная генерация ключей
            let result = await self.mockGenerateKeysUnknownDurationWithFailure()

            if Task.isCancelled { return }

            self.uiTask?.cancel()
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

    // MARK: - Mock

    private func mockGenerateKeysUnknownDurationWithFailure() async -> Result<Void, Error> {
        let seconds = Double.random(in: 1.0...8.0)
        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))

        // Мок: иногда падаем
        let shouldFail = Bool.random() && Bool.random() // ~25%
        if shouldFail {
            return .failure(NSError(domain: "CreateKeys", code: 1))
        } else {
            return .success(())
        }
    }

    deinit {
        uiTask?.cancel()
        workTask?.cancel()
    }
}
