//
//  ContactsView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 27.02.2026.
//

import SwiftUI
import PQUIComponents

struct ContactsView: View {
    
    // MARK: - Properties

    @ObservedObject private var viewModel: ContactsViewModel
    
    // MARK: - Body

    var body: some View {
        BackgroundView(isImage: true) {
            contentView
                .safeAreaInset(edge: .bottom) {
                    addContactButton
                        .padding(12)
                }
        }
    }
    
    // MARK: - Subviews
    
    private var contentView: some View {
        Group {
            if viewModel.filteredContacts.isEmpty {
                stubView
            } else {
                listView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Контакты")
                    .font(PQFont.B30)
                    .foregroundStyle(PQColor.base0.swiftUIColor)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                toolbarButtonsView
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Поиск")
        .searchToolbarBehavior(.minimize)
    }
    
    private var toolbarButtonsView: some View {
        HStack(spacing: 12) {
            PQImage.sliders.swiftUIImage
                .renderingMode(.template)
                .foregroundStyle(PQColor.base7.swiftUIColor)
                .onTapGesture(perform: viewModel.showFilters)
            
            PQImage.dots.swiftUIImage
                .renderingMode(.template)
                .foregroundStyle(PQColor.base7.swiftUIColor)
                .onTapGesture(perform: viewModel.showSettings)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
    
    private var stubView: some View {
        Text("Пока нет контактов")
            .font(PQFont.R16)
            .foregroundStyle(PQColor.purple2.swiftUIColor)
    }
    
    private var listView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.filteredContacts) { contact in
                    ContactView(
                        name: contact.name,
                        isVerified: contact.isVerified
                    )
                    .frame(maxWidth: .infinity)
                }
                
                Text("Verified – ключ подтверждён по независимому каналу.")
                    .font(PQFont.R12)
                    .foregroundStyle(PQColor.purple2.swiftUIColor)
            }
            .padding(.top)
            .padding(.horizontal)
            .padding(.bottom, 70)
        }
    }
    
    private var addContactButton: some View {
        PQImage.plus.swiftUIImage
            .renderingMode(.template)
            .foregroundStyle(PQColor.base7.swiftUIColor)
            .padding(8)
            .glassEffect(.regular.interactive(), in: Circle())
            .onTapGesture(perform: viewModel.addContact)
    }
    
    // MARK: - Initializer

    init(viewModel: ContactsViewModel) {
        self.viewModel = viewModel
    }
}
