//
//  CreateContainerFilesView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 13.04.2026.
//

import SwiftUI
import PQUIComponents
import PhotosUI
import UniformTypeIdentifiers

struct CreateContainerFilesView: View {

    // MARK: - Properties

    @ObservedObject private var viewModel: CreateContainerFilesViewModel
    @State private var selectedPhotoItems: [PhotosPickerItem] = []

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    // MARK: - Body

    var body: some View {
        BackgroundView {
            contentView
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationBarTitleDisplayMode(.inline)
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
    }

    // MARK: - Subviews

    private var contentView: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerView

                if viewModel.hasFiles {
                    filesGridView
                }
            }
            .padding(.horizontal)
        }
        .safeAreaInset(edge: .bottom) {
            if viewModel.hasFiles {
                PQButton(
                    String(localized: "shared.create"),
                    style: .init(.purple),
                    action: viewModel.create
                )
                .padding(.horizontal)
            }
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text(String(localized: "containers.create.files.title"))
                    .font(PQFont.B30)
                    .foregroundStyle(PQColor.base10.swiftUIColor)
                
                Text(String(localized: "containers.create.files.subtitle"))
                    .font(PQFont.R14)
                    .foregroundStyle(PQColor.base5.swiftUIColor)
            }
            
            PQButton(
                String(localized: "shared.add.files"),
                icon: PQImage.import.swiftUIImage,
                style: .init(.primary),
                action: viewModel.presentAddFilesSheet
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var filesGridView: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(viewModel.files) { file in
                FileCardView(file: file, showBadges: false, style: .dark)
                    .onTapGesture {
                        viewModel.openFile(file)
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            viewModel.removeFile(file)
                        } label: {
                            Label(String(localized: "shared.delete"), systemImage: "trash")
                        }
                    }
            }
        }
    }

    // MARK: - Init

    init(viewModel: CreateContainerFilesViewModel) {
        self.viewModel = viewModel
    }
}
