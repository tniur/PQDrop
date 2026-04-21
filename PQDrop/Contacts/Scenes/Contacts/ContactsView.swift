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
        .onAppear(perform: viewModel.loadContacts)
    }
    
    // MARK: - Subviews
    
    private var contentView: some View {
        ScrollView(showsIndicators: false) {
            if viewModel.filteredContacts.isEmpty {
                stubView
            } else {
                listContent
            }
        }
        .refreshable {
            viewModel.loadContacts()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(String(localized: "contacts.title"))
                    .font(PQFont.B30)
                    .foregroundStyle(PQColor.base0.swiftUIColor)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                toolbarButtonsView
            }
        }
        .searchable(text: $viewModel.searchText, prompt: String(localized: "shared.search"))
        .searchToolbarBehavior(.minimize)
        .alert(
            String(localized: "contacts.delete.alert.title"),
            isPresented: Binding(
                get: { viewModel.contactToDelete != nil },
                set: { if !$0 { viewModel.contactToDelete = nil } }
            ),
            actions: {
                Button(String(localized: "shared.delete"), role: .destructive) {
                    if let contact = viewModel.contactToDelete {
                        viewModel.delete(contact: contact)
                    }
                }
                Button(String(localized: "shared.cancel"), role: .cancel) {}
            },
            message: {
                if let contact = viewModel.contactToDelete {
                    Text(String(localized: "contacts.delete.alert.message\(contact.name)"))
                }
            }
        )
    }
    
    private var toolbarButtonsView: some View {
        HStack(spacing: 12) {
            PQImage.sliders.swiftUIImage
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(PQColor.base7.swiftUIColor)
                .frame(width: 32, height: 32)
                .onTapGesture(perform: viewModel.showFilters)
            
            Menu {
                Button(role: .destructive) {
                    viewModel.showClearAlert = true
                } label: {
                    Label(String(localized: "contacts.clear.menu"), systemImage: "trash")
                }
            } label: {
                PQImage.dots.swiftUIImage
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(PQColor.base7.swiftUIColor)
                    .frame(width: 32, height: 32)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .alert(String(localized: "contacts.clear.alert.title"), isPresented: $viewModel.showClearAlert) {
            Button(String(localized: "contacts.clear.alert.confirm"), role: .destructive) {
                viewModel.clearContacts()
            }
            Button(String(localized: "shared.cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "contacts.clear.alert.message"))
        }
    }
    
    private var stubView: some View {
        Text(String(localized: "contacts.empty.title"))
            .font(PQFont.R16)
            .foregroundStyle(PQColor.purple2.swiftUIColor)
            .frame(maxWidth: .infinity)
            .padding(.top, 80)
    }
    
    private var listContent: some View {
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
                        Label(String(localized: "shared.delete"), systemImage: "trash")
                    }
                }
            }
            
            Text(String(localized: "contacts.verified.hint"))
                .font(PQFont.R12)
                .foregroundStyle(PQColor.purple2.swiftUIColor)
        }
        .padding(.top)
        .padding(.horizontal)
    }
    
    private var addContactButton: some View {
        PQImage.plus.swiftUIImage
            .resizable()
            .renderingMode(.template)
            .foregroundStyle(PQColor.base7.swiftUIColor)
            .frame(width: 32, height: 32)
            .padding(8)
            .glassEffect(.regular.interactive(), in: Circle())
            .onTapGesture(perform: viewModel.addContact)
    }
    
    // MARK: - Initializer

    init(viewModel: ContactsViewModel) {
        self.viewModel = viewModel
    }
}
