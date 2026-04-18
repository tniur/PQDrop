//
//  ContainerContentsView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 07.04.2026.
//

import SwiftUI
import PQUIComponents
import PhotosUI
import UniformTypeIdentifiers

struct ContainerContentsView: View {

    // MARK: - Properties

    @ObservedObject private var viewModel: ContainerContentsViewModel
    @State private var selectedPhotoItems: [PhotosPickerItem] = []

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    // MARK: - Body

    var body: some View {
        BackgroundView(isImage: true) {
           contentView
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showShareSheet) {
            if let shareItem = viewModel.shareItem {
                ActivityViewControllerRepresentable(activityItems: [shareItem])
            }
        }
        .sheet(isPresented: $viewModel.showAddFilesSheet) {
            AddFilesSourceSheetView(
                onFilesTap: viewModel.openFilesImporter,
                onGalleryTap: viewModel.openPhotosPicker
            )
        }
        .fileImporter(
            isPresented: $viewModel.showFilesImporter,
            allowedContentTypes: [.item],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                viewModel.handleImportedFiles(urls: urls)
            case .failure:
                break
            }
        }
        .photosPicker(
            isPresented: $viewModel.showPhotosPicker,
            selection: $selectedPhotoItems,
            maxSelectionCount: nil,
            matching: .images,
            preferredItemEncoding: .current
        )
        .onChange(of: selectedPhotoItems) { items in
            guard !items.isEmpty else { return }

            Task {
                await viewModel.handlePickedPhotos(items)
                selectedPhotoItems = []
            }
        }
        .alert(
            String(localized: "containers.contents.save.alert.title"),
            isPresented: $viewModel.showSaveAlert
        ) {
            Button(String(localized: "shared.save")) {
                viewModel.save()
            }

            Button(String(localized: "shared.cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "containers.contents.save.alert.message"))
        }
    }

    // MARK: - Subviews
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerCardView

                if viewModel.isEmptyState {
                    emptyStateView
                } else {
                    filesGridView
                }

                footerView
            }
            .padding(.horizontal)
        }
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

                Text(String(localized: "shared.id\(viewModel.container.id)"))
                    .font(PQFont.R15)
                    .foregroundStyle(PQColor.base5.swiftUIColor)
                    .onTapGesture(perform: viewModel.copyId)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.vertical, 20)
        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 34))
    }

    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Text(String(localized: "containers.contents.empty.title"))
                .font(PQFont.B16)
                .foregroundStyle(PQColor.base0.swiftUIColor)

            Text(String(localized: "containers.contents.empty.subtitle"))
                .font(PQFont.R12)
                .foregroundStyle(PQColor.blue2.swiftUIColor)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
    }

    private var filesGridView: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(viewModel.files) { file in
                FileCardView(file: file)
                    .onTapGesture {
                        viewModel.openFile(file)
                    }
                    .contextMenu {
                        Button {
                            viewModel.exportFile(file)
                        } label: {
                            Label(String(localized: "shared.export"), systemImage: "square.and.arrow.up")
                        }

                        if file.isMarkedForDeletion {
                            Button {
                                viewModel.toggleDeletion(for: file)
                            } label: {
                                Label(String(localized: "shared.restore"), systemImage: "arrow.uturn.backward")
                            }
                        } else {
                            Button(role: .destructive) {
                                viewModel.toggleDeletion(for: file)
                            } label: {
                                Label(String(localized: "shared.delete"), systemImage: "trash")
                            }
                        }
                    }
            }
        }
    }

    @ViewBuilder
    private var footerView: some View {
        if viewModel.hasUnsavedChanges {
            VStack(spacing: 10) {
                Text(String(localized: "containers.contents.unsaved.title"))
                    .font(PQFont.B16)
                    .foregroundStyle(PQColor.blue1.swiftUIColor)

                VStack(spacing: 8) {
                    PQButton(
                        String(localized: "shared.add.files"),
                        icon: PQImage.import.swiftUIImage,
                        style: .init(.purple),
                        action: viewModel.presentAddFilesSheet
                    )

                    PQButton(
                        String(localized: "shared.save"),
                        style: .init(.primary),
                        action: viewModel.confirmSave
                    )

                    Text(String(localized: "containers.contents.unsaved.subtitle"))
                        .font(PQFont.R12)
                        .foregroundStyle(PQColor.blue1.swiftUIColor)
                        .multilineTextAlignment(.center)
                }
            }
        } else {
            PQButton(
                String(localized: "shared.add.files"),
                icon: PQImage.import.swiftUIImage,
                style: .init(.purple),
                action: viewModel.presentAddFilesSheet
            )
        }
    }

    // MARK: - Init

    init(viewModel: ContainerContentsViewModel) {
        self.viewModel = viewModel
    }
}
