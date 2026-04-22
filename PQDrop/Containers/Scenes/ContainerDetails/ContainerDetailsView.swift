//
//  ContainerDetailsView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 22.03.2026.
//

import SwiftUI
import PQUIComponents

struct ContainerDetailsView: View {

    // MARK: - Properties

    @ObservedObject private var viewModel: ContainerDetailsViewModel

    // MARK: - Body

    var body: some View {
        BackgroundView(isImage: true) {
            Group {
                if viewModel.isError {
                    errorView
                } else {
                    contentView
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            String(localized: "containers.delete.alert.title"),
            isPresented: $viewModel.showDeleteAlert
        ) {
            Button(String(localized: "shared.delete"), role: .destructive) {
                viewModel.deleteContainer()
            }
            Button(String(localized: "shared.cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "containers.details.delete.alert.message"))
        }
        .sheet(isPresented: $viewModel.showShareSheet) {
            ActivityViewControllerRepresentable(activityItems: [viewModel.container.fileURL as Any].compactMap { $0 })
        }
        .onAppear {
            viewModel.reload()
        }
        .sheet(isPresented: $viewModel.showHistorySheet) {
            ContainerHistorySheetView(
                events: viewModel.historyEvents,
                onShowAllTap: viewModel.showAllHistory
            )
        }
    }

    // MARK: - Subviews

    private var contentView: some View {
        VStack(spacing: 12) {
            headerCardView
            actionButtonsRow
            menuRowsView
            
            if !viewModel.isAvailable {
                Text(String(localized: "containers.details.no.access"))
                    .font(PQFont.R14)
                    .foregroundStyle(PQColor.base0.swiftUIColor)
                    .multilineTextAlignment(.center)
            }
            
            PQButton(
                String(localized: "shared.delete"),
                style: .init(.secondary),
                action: viewModel.confirmDelete
            )
            
            Spacer()
        }
        .padding(.horizontal)
    }

    private var headerCardView: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                HStack(spacing: 10) {
                    Text(viewModel.container.name)
                        .font(PQFont.B24)
                        .foregroundStyle(PQColor.base7.swiftUIColor)
                    
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
                }
                
                Text("id: \(viewModel.container.id.uuidString)")
                    .font(PQFont.R15)
                    .foregroundStyle(PQColor.base5.swiftUIColor)
                    .onTapGesture(perform: viewModel.copyId)
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
            (viewModel.isAvailable
             ? PQImage.done.swiftUIImage
             : PQImage.xmark.swiftUIImage)
            .resizable()
            .renderingMode(.template)
            .frame(width: 18, height: 18)
            .foregroundStyle(PQColor.base0.swiftUIColor)
            
            Text(String(localized: viewModel.isAvailable ? "shared.available" : "shared.unavailable"))
                .font(PQFont.B14)
                .foregroundStyle(PQColor.base0.swiftUIColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4.5)
        .background(
            Capsule()
                .foregroundStyle(
                    viewModel.isAvailable
                    ? PQColor.green5.swiftUIColor
                    : PQColor.base4.swiftUIColor
                )
        )
    }

    private var actionButtonsRow: some View {
        HStack(spacing: 8) {
            PQButton(
                String(localized: "containers.open"),
                icon: PQImage.box.swiftUIImage,
                action: viewModel.openContainer
            )
            .disabled(!viewModel.isAvailable || viewModel.isOpening)

            PQButton(
                String(localized: "shared.export"),
                icon: PQImage.export.swiftUIImage,
                action: viewModel.exportContainer
            )
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var menuRowsView: some View {
        if viewModel.isOwned {
            VStack(spacing: 12) {
                ChevronRowView(
                    icon: PQImage.contacts.swiftUIImage,
                    title: String(localized: "containers.recipients.title")
                )
                .onTapGesture(perform: viewModel.showRecipients)

                ChevronRowView(
                    icon: PQImage.export.swiftUIImage,
                    title: String(localized: "containers.access.management"),
                    isEnabled: viewModel.isAvailable
                )
                .onTapGesture(perform: viewModel.isAvailable ? viewModel.showAccessManagement : {})

                ChevronRowView(
                    icon: PQImage.clock.swiftUIImage,
                    title: String(localized: "containers.history.title")
                )
                .onTapGesture(perform: viewModel.showContainerHistory)
            }
        } else {
            PQButton(
                String(localized: "containers.copy.to.self"),
                icon: PQImage.copy.swiftUIImage,
                action: viewModel.copyContainerToSelf
            )
            .disabled(!viewModel.isAvailable)
        }
    }

    private var errorView: some View {
        VStack {
            Spacer()
            Text(String(localized: "containers.details.load.error"))
                .font(PQFont.R16)
                .foregroundStyle(PQColor.blue2.swiftUIColor)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }

    // MARK: - Init

    init(viewModel: ContainerDetailsViewModel) {
        self.viewModel = viewModel
    }
}
