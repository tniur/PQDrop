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
                Text(String(localized: "containers.edit.name.title"))
                    .font(PQFont.B30)
                    .foregroundStyle(PQColor.base10.swiftUIColor)

                contentView

                Spacer()

                if viewModel.shouldShowSubmitButton {
                    PQButton(
                        viewModel.buttonTitle,
                        style: PQButtonStyle(.purple),
                        action: viewModel.submit
                    )
                    .disabled(viewModel.name.isEmpty)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal)
            .animation(.easeInOut(duration: 0.2), value: viewModel.shouldShowSubmitButton)
        }
        .toolbar(.hidden, for: .tabBar)
    }

    // MARK: - Subviews

    private var contentView: some View {
        VStack(alignment: .leading, spacing: 8) {
            PQTextField(
                placeholderText: String(localized: "containers.edit.name.placeholder"),
                text: $viewModel.name
            )

            Text(String(localized: "containers.edit.name.hint"))
                .font(PQFont.R14)
                .foregroundStyle(PQColor.base5.swiftUIColor)
        }
    }

    // MARK: - Initializer

    init(viewModel: EditContainerNameViewModel) {
        self.viewModel = viewModel
    }
}
