//
//  EditContactNameView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 01.03.2026.
//

import SwiftUI
import PQUIComponents

struct EditContactNameView: View {
    
    // MARK: - Properties

    @ObservedObject private var viewModel: EditContactNameViewModel
    
    // MARK: - Body

    var body: some View {
        BackgroundView {
            VStack(alignment: .leading, spacing: 20) {
                Text(String(localized: "contacts.edit.name.title"))
                    .font(PQFont.B30)
                    .foregroundStyle(PQColor.base10.swiftUIColor)
                
                contentView
                
                Spacer()
                
                PQButton(
                    viewModel.buttonTitle,
                    style: PQButtonStyle(.purple),
                    action: viewModel.save
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
                placeholderText: String(localized: "contacts.edit.name.placeholder"),
                text: $viewModel.name
            )
            
            Text(String(localized: "contacts.edit.name.hint"))
                .font(PQFont.R14)
                .foregroundStyle(PQColor.base5.swiftUIColor)
        }
    }
    
    // MARK: - Initializer

    init(viewModel: EditContactNameViewModel) {
        self.viewModel = viewModel
    }
}
