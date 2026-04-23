//
//  AccessControlView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 22.03.2026.
//

import SwiftUI
import PQUIComponents

struct AccessControlView: View {

    // MARK: - Properties

    @ObservedObject private var viewModel: AccessControlViewModel

    // MARK: - Body

    var body: some View {
        BackgroundView(isImage: true) {
            contentView
        }
        .safeAreaInset(edge: .bottom) {
            footerView
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.hasUnsavedChanges)
        .toolbar(.hidden, for: .tabBar)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(String(localized: "containers.access.title"))
                    .font(PQFont.B16)
                    .foregroundStyle(PQColor.base0.swiftUIColor)
            }
        }
        .alert(item: $viewModel.activeAlert, content: makeAlert)
        .overlay {
            if viewModel.isProcessing {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .overlay {
                        ProgressView()
                            .tint(PQColor.base0.swiftUIColor)
                            .scaleEffect(1.5)
                    }
            }
        }
        .allowsHitTesting(!viewModel.isProcessing)
    }

    // MARK: - Subviews

    private var contentView: some View {
        VStack(spacing: 16) {
            headerCardView
                .padding(.horizontal)

            Text(String(localized: "containers.access.description"))
                .font(PQFont.R14)
                .foregroundStyle(PQColor.base0.swiftUIColor)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            contactsListView
        }
    }

    private var headerCardView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top, spacing: 8) {
                Text(viewModel.container.name)
                    .font(PQFont.B24)
                    .foregroundStyle(PQColor.base7.swiftUIColor)
                    .multilineTextAlignment(.leading)

                PQImage.pencil.swiftUIImage
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(PQColor.base7.swiftUIColor)
                    .frame(width: 16, height: 16)
                    .padding(9)
                    .background(
                        Circle()
                            .foregroundStyle(PQColor.base0.swiftUIColor)
                    )
                    .onTapGesture(perform: viewModel.editName)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(String(localized: "shared.id\(viewModel.container.id.uuidString)"))
                .font(PQFont.R15)
                .foregroundStyle(PQColor.base5.swiftUIColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical, 20)
        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 34))
    }

    private var contactsListView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                ForEach(viewModel.contacts) { contact in
                    AccessContactView(
                        name: contact.name,
                        shortKey: contact.shortFingerprint,
                        isVerified: contact.isVerified,
                        isSelected: viewModel.isSelected(contact.id)
                    )
                    .onTapGesture {
                        viewModel.toggleContact(contact.id)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
    }

    @ViewBuilder
    private var footerView: some View {
        if viewModel.hasUnsavedChanges {
            PQButton(
                String(localized: "shared.save"),
                style: .init(.primary),
                action: viewModel.confirmSaveChanges
            )
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
    }

    // MARK: - Init

    init(viewModel: AccessControlViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Methods

    private func makeAlert(_ alert: AccessControlAlert) -> Alert {
        switch alert {
        case .applyAccessChanges:
            return Alert(
                title: Text(
                    String(localized:
                        "containers.access.alert.apply.title\(viewModel.selectedContactIds.count)\(viewModel.contacts.count)"
                    )
                ),
                message: Text(String(localized: "containers.access.alert.changes.message")),
                primaryButton: .default(Text(String(localized: "shared.apply"))) {
                    viewModel.applySelectedContacts()
                },
                secondaryButton: .cancel(Text(String(localized: "shared.cancel")))
            )

        case .unverifiedWarning:
            return Alert(
                title: Text(String(localized: "containers.access.alert.unverified.title")),
                message: Text(String(localized: "containers.access.alert.unverified.message")),
                primaryButton: .default(Text(String(localized: "shared.continue"))) {
                    viewModel.applySelectedContacts()
                },
                secondaryButton: .cancel(Text(String(localized: "shared.cancel")))
            )

        case .operationFailed(let message):
            return Alert(
                title: Text(String(localized: "containers.access.alert.operation.failed.title")),
                message: Text(message),
                dismissButton: .default(Text(String(localized: "shared.got.it")))
            )
        }
    }
}
