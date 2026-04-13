//
//  CreateContainerSaveView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 13.04.2026.
//

import SwiftUI
import PQUIComponents

struct CreateContainerSaveView: View {

    // MARK: - Properties

    @ObservedObject private var viewModel: CreateContainerSaveViewModel

    private var title: String {
        switch viewModel.phase {
        case .loading:
            return ""
        case .success:
            return "Контейнер создан"
        case .failure:
            return "Не удалось\nсоздать контейнер"
        }
    }

    // MARK: - Body

    var body: some View {
        BackgroundView(isImage: true) {
            switch viewModel.phase {
            case .loading:
                loadingBlock
            case .success, .failure:
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
        case .failure:
            PQImage.exclamationMark.swiftUIImage
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.phase {
        case .loading:
            EmptyView()
        case .success:
            successBlock
        case .failure:
            failureBlock
        }
    }

    private var successBlock: some View {
        VStack(spacing: .zero) {
            Text("Контейнер сохранён\nв разделе \"Созданные\"")
                .font(PQFont.R14)
                .foregroundStyle(PQColor.blue2.swiftUIColor)
                .multilineTextAlignment(.center)

            Spacer()

            VStack(spacing: 8) {
                PQButton(
                    "Открыть контейнер",
                    style: .init(.primary),
                    action: viewModel.openContainer
                )

                PQButton(
                    "Перейти к списку",
                    style: .init(.secondary),
                    action: viewModel.goToList
                )
            }
        }
    }

    private var failureBlock: some View {
        VStack(spacing: .zero) {
            Text("Попробуйте ещё раз")
                .font(PQFont.R14)
                .foregroundStyle(PQColor.blue2.swiftUIColor)
                .multilineTextAlignment(.center)

            Spacer()

            VStack(spacing: 8) {
                PQButton(
                    "Повторить",
                    style: .init(.primary),
                    action: viewModel.retry
                )

                PQButton(
                    "Отмена",
                    style: .init(.secondary),
                    action: viewModel.cancel
                )
            }
        }
    }

    // MARK: - Initializer

    init(viewModel: CreateContainerSaveViewModel) {
        self.viewModel = viewModel
    }
}
