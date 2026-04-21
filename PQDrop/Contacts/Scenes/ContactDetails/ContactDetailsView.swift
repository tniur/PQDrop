//
//  ContactDetailsView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 04.03.2026.
//

import SwiftUI
import PQUIComponents

struct ContactDetailsView: View {
    
    // MARK: - Properties

    @ObservedObject private var viewModel: ContactDetailsViewModel
    
    private let fingerprintColumns = Array(
        repeating: GridItem(spacing: 12),
        count: 4
    )

    // MARK: - Body

    var body: some View {
        BackgroundView(isImage: true) {
           contentView
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                toolbarMenuView
            }
        }
        .alert(
            String(localized: "contacts.details.delete.confirm.title\(viewModel.contact.name)"),
            isPresented: $viewModel.showDeleteAlert
        ) {
            Button(String(localized: "shared.delete"), role: .destructive) {
                viewModel.deleteContact()
            }
            Button(String(localized: "shared.cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "contacts.details.delete.confirm.message"))
        }
        .alert(
            viewModel.verificationAlertTitle,
            isPresented: $viewModel.showVerificationAlert
        ) {
            Button(viewModel.verificationConfirmButtonTitle) {
                viewModel.confirmVerificationChange()
            }
            Button(String(localized: "shared.cancel"), role: .cancel) {
                viewModel.cancelVerificationChange()
            }
        } message: {
            Text(viewModel.verificationAlertMessage)
        }
    }
    
    // MARK: - Subviews

    private var contentView: some View {
        VStack(spacing: 10) {
            VStack(spacing: 28) {
                titleView
                fingerprintView
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.vertical, 40)
            .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 34))
            
            if !viewModel.contact.isVerified {
                Text(String(localized: "contacts.details.unverified.hint"))
                    .font(PQFont.B16)
                    .foregroundStyle(PQColor.base0.swiftUIColor)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
    }
    
    private var toolbarMenuView: some View {
        Menu {
            Button(role: .destructive) {
                viewModel.showDeleteAlert = true
            } label: {
                Label(String(localized: "contacts.details.delete.menu"), systemImage: "trash")
            }
        } label: {
            PQImage.dots.swiftUIImage
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(PQColor.base7.swiftUIColor)
                .frame(width: 32, height: 32)
        }
    }
    
    private var titleView: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                Text(viewModel.contact.name)
                    .font(PQFont.B30)
                    .foregroundStyle(PQColor.base7.swiftUIColor)
                
                PQImage.pencil.swiftUIImage
                    .renderingMode(.template)
                    .foregroundStyle(PQColor.base7.swiftUIColor)
                    .padding(9)
                    .background(
                        Circle()
                            .foregroundStyle(PQColor.base0.swiftUIColor)
                    )
                    .onTapGesture(perform: viewModel.editName)
            }
            
            Picker("", selection: viewModel.verifiedSelection) {
                Text(String(localized: "shared.status.verified")).tag(0)
                Text(String(localized: "shared.status.unverified")).tag(1)
            }
            .pickerStyle(.segmented)
            .frame(width: 200)
        }
    }
    
    private var fingerprintView: some View {
        VStack(spacing: 4) {
            LazyVGrid(columns: fingerprintColumns, spacing: 2) {
                ForEach(viewModel.fingerprintBlocks) { block in
                    Text(block.text)
                        .font(PQFont.R14)
                        .foregroundStyle(PQColor.base7.swiftUIColor)
                        .frame(maxWidth: .infinity)
                }
            }
            
            Text(String(localized: "contacts.details.fingerprint.hint"))
                .font(PQFont.R12.italic())
                .foregroundStyle(PQColor.blue3.swiftUIColor)
                .multilineTextAlignment(.center)
        }
        .contentShape(.rect)
        .frame(maxWidth: .infinity)
        .onTapGesture(perform: viewModel.copyFingerprint)
    }
    
    // MARK: - Init

    init(viewModel: ContactDetailsViewModel) {
        self.viewModel = viewModel
    }
}
