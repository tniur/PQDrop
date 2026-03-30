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
        .toolbar(.hidden, for: .tabBar)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Доступ")
                    .font(PQFont.B16)
                    .foregroundStyle(PQColor.base0.swiftUIColor)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button(action: viewModel.addContact) {
                    PQImage.plus.swiftUIImage
                        .renderingMode(.template)
                        .foregroundStyle(PQColor.base8.swiftUIColor)
                }
            }
        }
        .alert(
            viewModel.alertTitle,
            isPresented: $viewModel.isShowingApplyAlert
        ) {
            if viewModel.hasSelection, viewModel.hasPendingChanges {
                Button("Применить") {
                    viewModel.applySelectedContacts()
                }

                Button("Отмена", role: .cancel) { }
            } else {
                Button("Понятно", role: .cancel) { }
            }
        } message: {
            Text(viewModel.alertMessage)
        }
    }

    // MARK: - Subviews

    private var contentView: some View {
        VStack(spacing: 16) {
            headerCardView

            Text("Выберите контакты, которым хотите выдать доступ к этому контейнеру. Изменения потребуют перешифровки – это займёт несколько минут.")
                .font(PQFont.R14)
                .foregroundStyle(PQColor.base0.swiftUIColor)

            countersView
            contactsListView
            Spacer()
        }
        .padding(.horizontal)
    }

    private var headerCardView: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text(viewModel.container.name)
                    .font(PQFont.B24)
                    .foregroundStyle(PQColor.base7.swiftUIColor)

                Text("id: \(viewModel.container.id)")
                    .font(PQFont.R15)
                    .foregroundStyle(PQColor.base5.swiftUIColor)
            }

            statusBadge
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.vertical, 20)
        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 34))
    }

    @ViewBuilder
    private var statusBadge: some View {
        HStack(spacing: 2) {
            (viewModel.container.isAvailable
             ? PQImage.done.swiftUIImage
             : PQImage.xmark.swiftUIImage)
            .resizable()
            .renderingMode(.template)
            .frame(width: 18, height: 18)
            .foregroundStyle(PQColor.base0.swiftUIColor)

            Text(viewModel.container.isAvailable ? "Доступен" : "Недоступен")
                .font(PQFont.B14)
                .foregroundStyle(PQColor.base0.swiftUIColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4.5)
        .background(
            Capsule()
                .foregroundStyle(
                    viewModel.container.isAvailable
                    ? PQColor.green5.swiftUIColor
                    : PQColor.base4.swiftUIColor
                )
        )
    }

    private var countersView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Text("Имеют доступ:")
                    .font(PQFont.B16)
                    .foregroundStyle(PQColor.base0.swiftUIColor)

                Text("\(viewModel.hasAccessContactIds.count)/\(viewModel.contacts.count)")
                    .font(PQFont.R16)
                    .foregroundStyle(PQColor.base0.swiftUIColor)
            }

            HStack(spacing: 4) {
                Text("Выбрано:")
                    .font(PQFont.B16)
                    .foregroundStyle(PQColor.base0.swiftUIColor)

                Text("\(viewModel.selectedContactIds.count)/\(viewModel.contacts.count)")
                    .font(PQFont.R16)
                    .foregroundStyle(PQColor.base0.swiftUIColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var contactsListView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                ForEach(viewModel.contacts) { contact in
                    AccessContactView(
                        name: contact.name,
                        shortKey: contact.shortKey,
                        isVerified: contact.isVerified,
                        hasAccess: viewModel.hasAccess(contact.id),
                        isSelected: viewModel.isSelected(contact.id)
                    )
                    .onTapGesture {
                        viewModel.toggleContact(contact.id)
                    }
                }
            }
        }
    }

    // MARK: - Init

    init(viewModel: AccessControlViewModel) {
        self.viewModel = viewModel
    }
}
