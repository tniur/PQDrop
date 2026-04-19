//
//  AddContactView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 01.03.2026.
//

import SwiftUI
import PQUIComponents

struct AddContactView: View {

    // MARK: - Properties

    @ObservedObject private var viewModel: AddContactViewModel
    
    @State private var isScannerActive = false

    // MARK: - Body

    var body: some View {
        BackgroundView {
            VStack(alignment: .leading, spacing: 20) {
                titleView
                contentView
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
        .toolbar(.hidden, for: .tabBar)
        .alert("Ошибка", isPresented: $viewModel.showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }

    // MARK: - Subviews

    private var titleView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Добавить контакт")
                .font(PQFont.B30)
                .foregroundStyle(PQColor.base10.swiftUIColor)

            Text("Отсканируйте QR контакта или скопируйте ключ из буфера.")
                .font(PQFont.R14)
                .foregroundStyle(PQColor.base5.swiftUIColor)
        }
    }
    
    private var contentView: some View {
        VStack(spacing: 12) {
            QRScannerView(isActive: $isScannerActive) { value in
                viewModel.handleScanned(value: value)
            }
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .foregroundStyle(PQColor.base2.swiftUIColor)
            )
            .onAppear {
                isScannerActive = true
                viewModel.resetProcessing()
            }
            .onDisappear { isScannerActive = false }

            PQButton(
                "Скопировать из буфера",
                style: PQButtonStyle(.purple),
                action: viewModel.pasteFromClipboard
            )
        }
    }
    
    // MARK: - Initializer

    init(viewModel: AddContactViewModel) {
        self.viewModel = viewModel
    }
}
