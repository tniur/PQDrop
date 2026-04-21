//
//  FileViewerView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 09.04.2026.
//

import SwiftUI
import QuickLook
import PQUIComponents

struct FileViewerView: View {

    // MARK: - Properties

    @ObservedObject private var viewModel: FileViewerViewModel

    // MARK: - Body

    var body: some View {
        contentView
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(PQColor.base0.swiftUIColor)
            .ignoresSafeArea(.container, edges: .bottom)
            .toolbar(.hidden, for: .tabBar)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(viewModel.item.name)
                        .font(PQFont.B14)
                        .foregroundStyle(PQColor.base7.swiftUIColor)
                        .lineLimit(1)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: viewModel.exportFile) {
                        PQImage.export.swiftUIImage
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(PQColor.base7.swiftUIColor)
                            .frame(width: 36, height: 36)
                            .padding(4)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showShareSheet) {
                if let url = viewModel.item.localURL {
                    ActivityViewControllerRepresentable(activityItems: [url])
                }
            }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var contentView: some View {
        if viewModel.canPreview, let url = viewModel.item.localURL {
            QuickLookPreviewRepresentable(url: url)
        } else {
            unavailableView
        }
    }

    private var unavailableView: some View {
        VStack(spacing: 12) {
            Spacer()

            Text(String(localized: "files.viewer.error.title"))
                .font(PQFont.B24)
                .foregroundStyle(PQColor.base7.swiftUIColor)

            Text(String(localized: "files.viewer.error.message"))
                .font(PQFont.R14)
                .foregroundStyle(PQColor.base5.swiftUIColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Init

    init(viewModel: FileViewerViewModel) {
        self.viewModel = viewModel
    }
}
