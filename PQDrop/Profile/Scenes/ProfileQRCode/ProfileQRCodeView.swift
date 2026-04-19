//
//  ProfileQRCodeView.swift
//  PQDrop
//
//  Created by Pavel Bobkov on 19.04.2026.
//

import SwiftUI
import UIKit
import PQUIComponents

struct ProfileQRCodeView: View {

    // MARK: - Properties

    @ObservedObject private var viewModel: ProfileQRCodeViewModel

    private let fingerprintColumns = Array(
        repeating: GridItem(spacing: 12),
        count: 4
    )

    // MARK: - Body

    var body: some View {
        BackgroundView(isImage: true) {
            ZStack(alignment: .top) {
                contentView
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }

    // MARK: - Subviews

    private var contentView: some View {
        VStack(alignment: .center) {
            VStack(spacing: 18) {
                qrTileView
                fingerprintView
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 40)
            .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 34))
            .contentShape(.rect)
            .onTapGesture(perform: viewModel.copyCode)

            Spacer()
        }
        .padding(.top, 20)
    }

    private var qrTileView: some View {
        VStack(spacing: 8) {
            qrCodeImage
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)

            Text("Нажмите, чтобы скопировать")
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
        Group {
            if let image = viewModel.qrCodeImage {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(PQColor.base2.swiftUIColor)
                    .overlay {
                        Text("QR")
                            .font(PQFont.B30)
                            .foregroundStyle(PQColor.base6.swiftUIColor)
                    }
            }
        }
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
    
    // MARK: - Initializer

    init(viewModel: ProfileQRCodeViewModel) {
        self.viewModel = viewModel
    }
}
