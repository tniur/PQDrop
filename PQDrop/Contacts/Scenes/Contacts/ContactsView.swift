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
            
            Menu {
                Button(role: .destructive) {
                    viewModel.showClearAlert = true
                } label: {
                    Label("Очистить контакты", systemImage: "trash")
                }
            } label: {
                PQImage.dots.swiftUIImage
                    .renderingMode(.template)
                    .foregroundStyle(PQColor.base7.swiftUIColor)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .alert("Очистить все контакты?", isPresented: $viewModel.showClearAlert) {
            Button("Удалить все", role: .destructive) {
                viewModel.clearContacts()
            }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Все контакты будут удалены.")
        }
    }
    
    private var stubView: some View {
        Text("Пока нет контактов")
            .font(PQFont.R16)
            .foregroundStyle(PQColor.purple2.swiftUIColor)
    }
    
    private var listView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.filteredContacts) { contact in
                    ContactView(
                        name: contact.name,
                        isVerified: contact.isVerified
                    )
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        viewModel.showDetails(of: contact)
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            viewModel.contactToDelete = contact
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                    }
                }
                
                Text("Verified – ключ подтверждён по независимому каналу.")
                    .font(PQFont.R12)
                    .foregroundStyle(PQColor.purple2.swiftUIColor)
            }
            .padding(.top)
            .padding(.horizontal)
        }
        .alert(
            "Удалить контакт?",
            isPresented: Binding(
                get: { viewModel.contactToDelete != nil },
                set: { if !$0 { viewModel.contactToDelete = nil } }
            ),
            actions: {
                Button("Удалить", role: .destructive) {
                    if let contact = viewModel.contactToDelete {
                        viewModel.delete(contact: contact)
                    }
                }
                Button("Отмена", role: .cancel) {}
            },
            message: {
                if let contact = viewModel.contactToDelete {
                    Text("Контакт «\(contact.name)» будет удалён.")
                }
            }
        )
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
