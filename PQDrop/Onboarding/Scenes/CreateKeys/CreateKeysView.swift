//
//  CreateKeysView.swift
//  PQDrop
//
//  Created by Анастасия Журавлеva on 19.02.2026.
//

import SwiftUI
import PQUIComponents

struct CreateKeysView: View {

    // MARK: - Properties

    @ObservedObject private var viewModel: CreateKeysViewModel

    private var title: String {
        switch viewModel.phase {
        case .idle, .creating:
            return "Создание ключей"
        case .success:
            return "Ключи созданы"
        case .failure:
            return "Не удалось создать ключи"
        }
    }
    
    // MARK: - Body

    var body: some View {
        BackgroundView(isImage: true) {
            VStack(spacing: .zero) {
                imageView
                    .frame(maxWidth: .infinity)
                    .frame(height: 162)
                    .padding(.bottom, 40)

                Text(title)
                    .font(PQFont.B30)
                    .foregroundStyle(PQColor.base0.swiftUIColor)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)

                content

                Spacer()
            }
            .padding(.top, 40)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var imageView: some View {
        switch viewModel.phase {
        case .idle, .creating:
            PQImage.key.swiftUIImage
        case .success:
            PQImage.doneCheckmark.swiftUIImage
        case .failure:
            PQImage.exclamationMark.swiftUIImage
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.phase {
        case .idle:
            idleBlock
        case .creating:
            creatingBlock
        case .success:
            successBlock
        case .failure:
            failureBlock
        }
    }

    private var idleBlock: some View {
        VStack(spacing: .zero) {
            Text("Ключи нужны для шифрования контейнеров и выдачи доступа другим людям. Они сохраняются в защищённом хранилище iOS.")
                .font(PQFont.R14)
                .foregroundStyle(PQColor.blue2.swiftUIColor)
                .multilineTextAlignment(.center)
                .padding(.bottom, 24)

            PQButton("Сгенерировать ключи") {
                viewModel.createKeys()
            }
        }
    }

    private var creatingBlock: some View {
        VStack(spacing: 8) {
            ProgressView(value: viewModel.progress, total: 1.0)
                .tint(PQColor.blue6.swiftUIColor)
                .frame(height: 6)
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                )

            Text(viewModel.status.text)
                .font(PQFont.R14)
                .foregroundStyle(PQColor.blue2.swiftUIColor)
                .multilineTextAlignment(.center)
        }
        .transition(.opacity)
        .animation(.easeInOut, value: viewModel.status)
    }

    private var successBlock: some View {
        VStack(spacing: .zero) {
            Text("Теперь вы можете шифровать файлы и выдавать доступ через QR‑коды.")
                .font(PQFont.R14)
                .foregroundStyle(PQColor.blue2.swiftUIColor)
                .multilineTextAlignment(.center)

            Spacer()
            
            PQButton(
                "Далее",
                action: viewModel.finish
            )
        }
    }

    private var failureBlock: some View {
        VStack(spacing: .zero) {
            Text("Попробуйте ещё раз. Если ошибка повторится — проверьте свободное место и настройки безопасности устройства.")
                .font(PQFont.R14)
                .foregroundStyle(PQColor.blue2.swiftUIColor)
                .multilineTextAlignment(.center)

            Spacer()

            PQButton("Повторить", action: viewModel.retry)
        }
    }

    // MARK: - Initializer

    init(viewModel: CreateKeysViewModel) {
        self.viewModel = viewModel
    }
}
