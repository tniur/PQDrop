//
//  ImportContainerView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 15.04.2026.
//

import SwiftUI
import PQUIComponents

struct ImportContainerView: View {

    // MARK: - Properties

    @ObservedObject private var viewModel: ImportContainerViewModel

    private var title: String {
        switch viewModel.phase {
        case .loading:
            return ""
        case .success:
            return String(localized: "containers.import.result.success.title")
        case .invalidFormat:
            return String(localized: "containers.import.result.invalid.title")
        case .accessDenied:
            return String(localized: "containers.import.result.access.denied.title")
        }
    }

    // MARK: - Body

    var body: some View {
        BackgroundView(isImage: true) {
            switch viewModel.phase {
            case .loading:
                loadingBlock
            case .success, .invalidFormat, .accessDenied:
                resultBlock
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }

    // MARK: - Subviews

    private var loadingBlock: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(PQColor.base0.swiftUIColor)
                .scaleEffect(1.2)

            Text(viewModel.status.text)
                .font(PQFont.R14)
                .foregroundStyle(PQColor.blue2.swiftUIColor)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.opacity)
        .animation(.easeInOut, value: viewModel.status)
    }

    private var resultBlock: some View {
        VStack(spacing: 40) {
            Spacer(minLength: 104)

            imageView
                .frame(maxWidth: .infinity)
                .frame(height: 162)

            VStack(spacing: 20) {
                Text(title)
                    .font(PQFont.B30)
                    .foregroundStyle(PQColor.base0.swiftUIColor)
                    .multilineTextAlignment(.center)

                content
            }
        }
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private var imageView: some View {
        switch viewModel.phase {
        case .loading:
            EmptyView()
        case .success:
            PQImage.doneCheckmark.swiftUIImage
        case .invalidFormat:
            PQImage.exclamationMark.swiftUIImage
        case .accessDenied:
            PQImage.lock.swiftUIImage
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.phase {
        case .loading:
            EmptyView()
        case .success:
            successBlock
        case .invalidFormat:
            invalidFormatBlock
        case .accessDenied:
            accessDeniedBlock
        }
    }

    private var successBlock: some View {
        VStack(spacing: .zero) {
            Text(String(localized: "containers.import.result.success.message"))
                .font(PQFont.R14)
                .foregroundStyle(PQColor.blue2.swiftUIColor)
                .multilineTextAlignment(.center)

            Spacer()

            VStack(spacing: 8) {
                PQButton(
                    String(localized: "containers.open"),
                    style: .init(.primary),
                    action: viewModel.openContainer
                )

                PQButton(
                    String(localized: "shared.go.to.list"),
                    style: .init(.secondary),
                    action: viewModel.goToList
                )
            }
        }
    }

    private var invalidFormatBlock: some View {
        VStack(spacing: .zero) {
            Text(String(localized: "containers.import.result.invalid.message"))
                .font(PQFont.R14)
                .foregroundStyle(PQColor.blue2.swiftUIColor)
                .multilineTextAlignment(.center)

            Spacer()

            PQButton(
                String(localized: "shared.ok"),
                style: .init(.primary),
                action: viewModel.returnToList
            )
        }
    }

    private var accessDeniedBlock: some View {
        VStack(spacing: .zero) {
            Text(String(localized: "containers.import.result.access.denied.message"))
                .font(PQFont.R14)
                .foregroundStyle(PQColor.blue2.swiftUIColor)
                .multilineTextAlignment(.center)

            Spacer()

            PQButton(
                String(localized: "containers.return.to.list"),
                style: .init(.primary),
                action: viewModel.returnToList
            )
        }
    }

    // MARK: - Initializer

    init(viewModel: ImportContainerViewModel) {
        self.viewModel = viewModel
    }
}
