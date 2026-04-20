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
            "Сохранить изменения?",
            isPresented: $viewModel.showSaveAlert
        ) {
            Button("Сохранить") {
                viewModel.save()
            }

            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Файлы в контейнере будут обновлены. После этого начнётся перешифровка, и это может занять некоторое время.")
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

                Text("id: \(viewModel.container.id.uuidString)")
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
            Text("Контейнер пуст")
                .font(PQFont.B16)
                .foregroundStyle(PQColor.base0.swiftUIColor)

            Text("Добавьте файлы, чтобы сохранить их в зашифрованном контейнере")
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
                            Label("Экспортировать", systemImage: "square.and.arrow.up")
                        }

                        if file.isMarkedForDeletion {
                            Button {
                                viewModel.toggleDeletion(for: file)
                            } label: {
                                Label("Вернуть", systemImage: "arrow.uturn.backward")
                            }
                        } else {
                            Button(role: .destructive) {
                                viewModel.toggleDeletion(for: file)
                            } label: {
                                Label("Удалить", systemImage: "trash")
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
                Text("Изменения не сохранены")
                    .font(PQFont.B16)
                    .foregroundStyle(PQColor.blue1.swiftUIColor)

                VStack(spacing: 8) {
                    PQButton(
                        "Добавить файлы",
                        icon: PQImage.import.swiftUIImage,
                        style: .init(.purple),
                        action: viewModel.presentAddFilesSheet
                    )

                    PQButton(
                        "Сохранить",
                        style: .init(.primary),
                        action: viewModel.confirmSave
                    )

                    Text("После сохранения контейнер будет перешифрован")
                        .font(PQFont.R12)
                        .foregroundStyle(PQColor.blue1.swiftUIColor)
                        .multilineTextAlignment(.center)
                }
            }
        } else {
            PQButton(
                "Добавить файлы",
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
