//
//  ContactDetailsView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 04.03.2026.
//

import SwiftUI
import PQUIComponents

struct ContactDetailsView: View {
    
    // MARK: - Properties

    @ObservedObject private var viewModel: ContactDetailsViewModel
    
    private let fingerprintColumns = Array(
        repeating: GridItem(spacing: 12),
        count: 4
    )

    // MARK: - Body

    var body: some View {
        BackgroundView(isImage: true) {
            VStack(spacing: 10) {
                contentView
                    .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 34))
                
                if !viewModel.contact.isVerified {
                    Text("Это неподтверждённый контакт. Перед выдачей доступа проверьте fingerprint по независимому каналу.")
                        .font(PQFont.B16)
                        .foregroundStyle(PQColor.base0.swiftUIColor)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Subviews

    private var contentView: some View {
        VStack(spacing: 28) {
            titleView
            fingerprintView
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.vertical, 40)
    }
    
    private var titleView: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                Text(viewModel.contact.name)
                    .font(PQFont.B30)
                    .foregroundStyle(PQColor.base7.swiftUIColor)
                
                PQImage.pencil.swiftUIImage
                    .renderingMode(.template)
                    .foregroundStyle(PQColor.base7.swiftUIColor)
                    .padding(9)
                    .background(
                        Circle()
                            .foregroundStyle(PQColor.base0.swiftUIColor)
                    )
                    .onTapGesture(perform: viewModel.editName)
            }
            
            Picker("", selection: viewModel.verifiedSelection) {
                Text("Verified")
                    .tag(0)
                Text("Unverified")
                    .tag(1)
            }
            .pickerStyle(.segmented)
            .frame(width: 200)
        }
    }
    
    private var fingerprintView: some View {
        VStack(spacing: 4) {
            LazyVGrid(columns: fingerprintColumns, spacing: 2) {
                ForEach(viewModel.fingerprintBlocks) { block in
                    Text(block.text)
                        .font(PQFont.R14)
                        .foregroundStyle(PQColor.base7.swiftUIColor)
                        .frame(maxWidth: .infinity)
                }
            }
            
            Text("нажмите на fingerprint, чтобы скопировать")
                .font(PQFont.R12.italic())
                .foregroundStyle(PQColor.blue2.swiftUIColor)
                .multilineTextAlignment(.center)
        }
        .contentShape(Rectangle())
        .frame(width: 248)
        .onTapGesture(perform: viewModel.copyFingerprint)
    }
    
    // MARK: - Init

    init(viewModel: ContactDetailsViewModel) {
        self.viewModel = viewModel
    }
}
