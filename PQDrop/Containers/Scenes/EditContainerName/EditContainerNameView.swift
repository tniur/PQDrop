//
//  EditContainerNameView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 13.04.2026.
//

import SwiftUI
import PQUIComponents

struct EditContainerNameView: View {

    // MARK: - Properties

    @ObservedObject private var viewModel: EditContainerNameViewModel

    // MARK: - Body

    var body: some View {
        BackgroundView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Название контейнера")
                    .font(PQFont.B30)
                    .foregroundStyle(PQColor.base10.swiftUIColor)

                contentView

                Spacer()

                PQButton(
                    viewModel.buttonTitle,
                    style: PQButtonStyle(.purple),
                    action: viewModel.submit
                )
                .disabled(viewModel.name.isEmpty)
            }
            .padding(.vertical, 4)
            .padding(.horizontal)
        }
        .toolbar(.hidden, for: .tabBar)
    }

    // MARK: - Subviews

    private var contentView: some View {
        VStack(alignment: .leading, spacing: 8) {
            PQTextField(
                placeholderText: "Введите название контейнера",
                text: $viewModel.name
            )

            Text("Контейнер — это зашифрованная папка с файлами.")
                .font(PQFont.R14)
                .foregroundStyle(PQColor.base5.swiftUIColor)
        }
    }

    // MARK: - Initializer

    init(viewModel: EditContainerNameViewModel) {
        self.viewModel = viewModel
    }
}
