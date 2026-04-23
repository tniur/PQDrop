//
//  ProfileView.swift
//  PQDrop
//
//  Created by Pavel Bobkov on 19.04.2026.
//

import SwiftUI
import UIKit
import PQUIComponents

struct ProfileView: View {
    
    // MARK: - Properties

    @ObservedObject private var viewModel: ProfileViewModel

    private let fingerprintColumns = Array(
        repeating: GridItem(spacing: 12),
        count: 4
    )
    
    // MARK: - Body

    var body: some View {
        BackgroundView(isImage: true) {
            contentView
        }
        .toolbar(.hidden, for: .navigationBar)
        .alert(
            String(localized: "profile.reset.alert.title"),
            isPresented: $viewModel.showResetAlert
        ) {
            Button(String(localized: "profile.reset.alert.confirm"), role: .destructive) {
                viewModel.resetAllData()
            }
            Button(String(localized: "shared.cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "profile.reset.alert.message"))
        }
    }

    // MARK: - Subviews

    private var contentView: some View {
        VStack(alignment: .center) {
            Text(String(localized: "profile.title"))
                .font(PQFont.B30)
                .foregroundStyle(PQColor.base0.swiftUIColor)
                .frame(maxWidth: .infinity, alignment: .leading)

            qrContentView

            Spacer()

            resetButton
        }
        .padding()
    }

    private var qrContentView: some View {
        VStack(spacing: 18) {
            qrTileView
            fingerprintView
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 40)
        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 34))
        .contentShape(.rect)
        .onTapGesture(perform: viewModel.copyCode)
    }

    private var qrTileView: some View {
        VStack(spacing: 8) {
            qrCodeImage
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)

            Text(String(localized: "profile.publicKey.copy.hint"))
                .font(PQFont.R12.italic())
                .foregroundStyle(PQColor.base5.swiftUIColor)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(PQColor.base0.swiftUIColor)
        )
    }

    private var qrCodeImage: some View {
        ZStack {
            if let image = viewModel.qrCodeImage {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .transition(.opacity)
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(PQColor.base2.swiftUIColor)
                    .overlay {
                        ProgressView()
                            .tint(PQColor.base6.swiftUIColor)
                    }
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.qrCodeImage == nil)
    }

    private var fingerprintView: some View {
        LazyVGrid(columns: fingerprintColumns, spacing: 2) {
            ForEach(viewModel.fingerprintBlocks) { block in
                Text(block.text)
                    .font(PQFont.R14)
                    .foregroundStyle(PQColor.base0.swiftUIColor)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var resetButton: some View {
        PQButton(
            String(localized: "profile.reset.button"),
            style: .init(.secondary, height: 42)
        ) {
            viewModel.showResetAlert = true
        }
    }
    
    // MARK: - Initializer

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
    }
}
