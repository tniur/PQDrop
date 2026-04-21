//
//  PQToast.swift
//  PQUIComponents
//
//  Created by Анастасия Журавлева on 21.04.2026.
//

import SwiftUI
import UIKit

public enum PQToast {

    // MARK: - Methods

    public static func show(with text: String, duration: Duration = .seconds(2)) {
        Task { @MainActor in
            Presenter.shared.show(text: text, duration: duration)
        }
    }
}

private extension PQToast {
    @MainActor
    final class Presenter {

        // MARK: - Shared

        static let shared = Presenter()

        // MARK: - Properties

        private var hostingController: UIHostingController<ToastView>?
        private var dismissTask: Task<Void, Never>?
        private var topConstraint: NSLayoutConstraint?
        private let hiddenTopConstant: CGFloat = -64

        // MARK: - Methods

        func show(text: String, duration: Duration) {
            dismissTask?.cancel()

            let window = activeWindow()
            let hostingController = makeHostingControllerIfNeeded()
            let visibleTopConstant = window.safeAreaInsets.top + 8

            hostingController.rootView = ToastView(text: text)

            if hostingController.view.superview !== window {
                hostingController.view.removeFromSuperview()
                hostingController.view.translatesAutoresizingMaskIntoConstraints = false
                hostingController.view.backgroundColor = .clear
                hostingController.view.isUserInteractionEnabled = false
                window.addSubview(hostingController.view)

                let topConstraint = hostingController.view.topAnchor.constraint(equalTo: window.topAnchor, constant: hiddenTopConstant)
                self.topConstraint = topConstraint

                NSLayoutConstraint.activate([
                    topConstraint,
                    hostingController.view.centerXAnchor.constraint(equalTo: window.centerXAnchor),
                    hostingController.view.leadingAnchor.constraint(greaterThanOrEqualTo: window.leadingAnchor, constant: 16),
                    hostingController.view.trailingAnchor.constraint(lessThanOrEqualTo: window.trailingAnchor, constant: -16)
                ])
            }

            topConstraint?.constant = hiddenTopConstant

            hostingController.view.alpha = 0
            window.layoutIfNeeded()

            UIView.animate(
                withDuration: 0.28,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 0.2
            ) {
                self.topConstraint?.constant = visibleTopConstant
                hostingController.view.alpha = 1
                window.layoutIfNeeded()
            }

            dismissTask = Task { [weak self] in
                try? await Task.sleep(for: duration)

                guard !Task.isCancelled else { return }
                await self?.hide()
            }
        }

        private func hide() {
            dismissTask?.cancel()
            dismissTask = nil

            guard let hostingController, let window = hostingController.view.superview else { return }

            UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut]) {
                self.topConstraint?.constant = self.hiddenTopConstant
                hostingController.view.alpha = 0
                window.layoutIfNeeded()
            } completion: { _ in
                hostingController.view.removeFromSuperview()
            }
        }

        private func makeHostingControllerIfNeeded() -> UIHostingController<ToastView> {
            if let hostingController {
                return hostingController
            }

            let hostingController = UIHostingController(rootView: ToastView(text: ""))
            self.hostingController = hostingController

            return hostingController
        }

        private func activeWindow() -> UIWindow {
            let connectedScenes = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .filter { $0.activationState == .foregroundActive }

            for scene in connectedScenes {
                if let window = scene.windows.first(where: \.isKeyWindow) {
                    return window
                }
            }

            if let window = connectedScenes.first?.windows.first {
                return window
            }

            fatalError("No active UIWindow available for PQToast")
        }
    }
}

private struct ToastView: View {

    // MARK: - Properties

    let text: String

    // MARK: - Body

    var body: some View {
        Text(text)
            .font(PQFont.B12)
            .foregroundStyle(PQColor.base10.swiftUIColor)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .foregroundStyle(PQColor.base0.swiftUIColor)
            )
    }
}
