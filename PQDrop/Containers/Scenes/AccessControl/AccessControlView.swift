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
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(PQColor.base8.swiftUIColor)
                        .frame(width: 32, height: 32)
                }
            }
        }
        .alert(item: $viewModel.activeAlert, content: makeAlert)
    }

    // MARK: - Subviews

    private var contentView: some View {
        VStack(spacing: 16) {
            headerCardView
                .padding(.horizontal)

            Text("Выберите контакты, которым хотите выдать доступ к этому контейнеру. Изменения потребуют перешифровки – это займёт несколько минут.")
                .font(PQFont.R14)
                .foregroundStyle(PQColor.base0.swiftUIColor)
                .padding(.horizontal)

            countersView
                .padding(.horizontal)

            contactsListView

            Spacer()
        }
    }

    private var headerCardView: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text(viewModel.container.name)
                    .font(PQFont.B24)
                    .foregroundStyle(PQColor.base7.swiftUIColor)

                Text("id: \(viewModel.container.id.uuidString)")
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
                    .contextMenu {
                        if viewModel.hasAccess(contact.id) {
                            Button(role: .destructive) {
                                viewModel.requestRevokeAccess(for: contact.id)
                            } label: {
                                Text("Ограничить доступ")
                                Image(systemName: "person.crop.circle.badge.minus")
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Init

    init(viewModel: AccessControlViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Methods

    private func makeAlert(_ alert: AccessControlAlert) -> Alert {
        switch alert {
        case .noSelection:
            return Alert(
                title: Text("Контакт не выбран"),
                message: Text("Выберите хотя бы один контакт, чтобы выдать доступ к контейнеру."),
                dismissButton: .cancel(Text("Понятно"))
            )

        case .applyAccessChanges:
            return Alert(
                title: Text("Выбрано \(viewModel.selectedContactIds.count) из \(viewModel.contacts.count) контактов"),
                message: Text("Добавление/удаление получателей требует перешифровки контейнера. Это может занять несколько минут."),
                primaryButton: .default(Text("Применить")) {
                    viewModel.applySelectedContacts()
                },
                secondaryButton: .cancel(Text("Отмена"))
            )

        case .revokeAccess(let contactId):
            return Alert(
                title: Text("Ограничить доступ?"),
                message: Text("Добавление/удаление получателей требует перешифровки контейнера. Это может занять несколько минут."),
                primaryButton: .destructive(Text("Применить")) {
                    viewModel.revokeAccess(for: contactId)
                },
                secondaryButton: .cancel(Text("Отмена"))
            )
        }
    }
}
