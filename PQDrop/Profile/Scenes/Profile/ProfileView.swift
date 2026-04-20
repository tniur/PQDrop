//
//  ProfileView.swift
//  PQDrop
//
//  Created by Pavel Bobkov on 19.04.2026.
//

import SwiftUI
import PQUIComponents

struct ProfileView: View {
    
    // MARK: - Properties

    @ObservedObject private var viewModel: ProfileViewModel
    
    // MARK: - Body

    var body: some View {
        BackgroundView(isImage: true) {
            contentView
        }
        .toolbar(.hidden, for: .navigationBar)
        .alert(
            "Очистить все данные?",
            isPresented: $viewModel.showResetAlert
        ) {
            Button("Очистить", role: .destructive) {
                viewModel.resetAllData()
            }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Будут удалены ключи, контейнеры, контакты и история. Это действие необратимо.")
        }
    }

    // MARK: - Subviews

    private var contentView: some View {
        VStack(spacing: 16) {
            PQImage.person.swiftUIImage

            PQButton(
                "Открыть QR код",
                action: viewModel.openQRCode
            )

            PQButton(
                "Очистить все данные",
                style: .init(.secondary, height: 42)
            ) {
                viewModel.showResetAlert = true
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    // MARK: - Initializer

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
    }
}
