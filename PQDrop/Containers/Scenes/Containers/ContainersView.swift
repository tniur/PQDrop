//
//  ContainersView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 20.03.2026.
//

import SwiftUI
import PQUIComponents
import UniformTypeIdentifiers

struct ContainersView: View {

    // MARK: - Properties

    @ObservedObject private var viewModel: ContainersViewModel

    // MARK: - Body

    var body: some View {
        BackgroundView(isImage: true) {
            contentView
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(String(localized: "containers.title"))
                            .font(PQFont.B30)
                            .foregroundStyle(PQColor.base0.swiftUIColor)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        toolbarButtonsView
                    }
                }
                .searchable(text: $viewModel.searchText, prompt: String(localized: "shared.search"))
                .searchToolbarBehavior(.minimize)
        }
        .fileImporter(
            isPresented: $viewModel.isFileImporterPresented,
            allowedContentTypes: [.item],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                viewModel.handleImportedFile(url: urls.first)
            case .failure:
                break
            }
        }
    }

    // MARK: - Subviews

    private var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                segmentedControl
                
                if viewModel.filteredContainers.isEmpty {
                    if viewModel.isSearchActive {
                        emptySearchView
                    } else {
                        emptyTabView
                    }
                } else {
                    containersList
                }
            }
            .padding()
        }
    }
    
    private var toolbarButtonsView: some View {
        HStack(spacing: 12) {
            PQImage.plus.swiftUIImage
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(PQColor.base7.swiftUIColor)
                .frame(width: 32, height: 32)
                .onTapGesture(perform: viewModel.createContainer)

            PQImage.import.swiftUIImage
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(PQColor.base7.swiftUIColor)
                .frame(width: 32, height: 32)
                .onTapGesture(perform: viewModel.importContainer)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
    }

    private var segmentedControl: some View {
        Picker("", selection: $viewModel.selectedTab) {
            Text(String(localized: "containers.tab.created")).tag(ContainersTab.created)
            Text(String(localized: "containers.tab.received")).tag(ContainersTab.received)
        }
        .pickerStyle(.segmented)
    }

    private var emptySearchView: some View {
        VStack(spacing: 8) {
            Text(String(localized: "shared.nothing.found"))
                .font(PQFont.B16)
                .foregroundStyle(PQColor.base0.swiftUIColor)

            Text(String(localized: "containers.search.empty.subtitle"))
                .font(PQFont.R12)
                .foregroundStyle(PQColor.blue2.swiftUIColor)
        }
        .multilineTextAlignment(.center)
        .containerRelativeFrame([.vertical], alignment: .center)
    }

    private var emptyTabView: some View {
        VStack(spacing: 12) {
            VStack(spacing: 8) {
                Text(viewModel.selectedTab.emptyTitle)
                    .font(PQFont.B16)
                    .foregroundStyle(PQColor.base0.swiftUIColor)

                Text(viewModel.selectedTab.emptySubtitle)
                    .font(PQFont.R12)
                    .foregroundStyle(PQColor.blue2.swiftUIColor)
            }
            .multilineTextAlignment(.center)

            PQButton(
                viewModel.selectedTab.emptyButtonTitle,
                style: .init(.primary, isCompact: true, height: 42),
                action: viewModel.emptyTabAction,
            )
        }
        .containerRelativeFrame([.vertical], alignment: .center)
    }

    private var containersList: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(viewModel.filteredContainers) { container in
                ContainerCardView(
                    name: container.name,
                    id: container.id,
                    isAvailable: container.isAvailable
                )
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    viewModel.showContainerDetails(container: container)
                }
                .contextMenu {
                    Button(role: .destructive) {
                        viewModel.containerToDelete = container
                    } label: {
                        Label(String(localized: "shared.delete"), systemImage: "trash")
                    }
                }
            }
        }
        .alert(
            String(localized: "containers.delete.alert.title"),
            isPresented: Binding(
                get: { viewModel.containerToDelete != nil },
                set: { if !$0 { viewModel.containerToDelete = nil } }
            ),
            actions: {
                Button(String(localized: "shared.delete"), role: .destructive) {
                    if let container = viewModel.containerToDelete {
                        viewModel.delete(container: container)
                    }
                }
                Button(String(localized: "shared.cancel"), role: .cancel) {}
            },
            message: {
                if let container = viewModel.containerToDelete {
                    Text(String(localized: "containers.delete.alert.message\(container.name)"))
                }
            }
        )
    }

    // MARK: - Initializer

    init(viewModel: ContainersViewModel) {
        self.viewModel = viewModel
    }
}
