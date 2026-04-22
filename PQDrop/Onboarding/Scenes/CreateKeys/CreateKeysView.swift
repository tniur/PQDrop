//
//  CreateKeysView.swift
//  PQDrop
//
//  Created by Анастасия Журавлеva on 19.02.2026.
//

import SwiftUI
import PQUIComponents

struct CreateKeysView: View {
    
    // MARK: - Properties
    
    @ObservedObject private var viewModel: CreateKeysViewModel
    
    private var title: String {
        switch viewModel.phase {
        case .idle, .creating:
            return String(localized: "onboarding.keys.title.creating")
        case .success:
            return String(localized: "onboarding.keys.title.success")
        case .failure:
            return String(localized: "onboarding.keys.title.failure")
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        BackgroundView(isImage: true) {
            VStack(spacing: .zero) {
                imageView
                    .frame(maxWidth: .infinity)
                    .frame(height: 162)
                    .padding(.bottom, 40)
                
                Text(title)
                    .font(PQFont.B30)
                    .foregroundStyle(PQColor.base0.swiftUIColor)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
                
                content
                
                Spacer()
            }
            .padding(.top, 40)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .safeAreaInset(edge: .bottom) {
            bottomButton
                .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var imageView: some View {
        switch viewModel.phase {
        case .idle, .creating:
            PQImage.key.swiftUIImage
        case .success:
            PQImage.doneCheckmark.swiftUIImage
        case .failure:
            PQImage.exclamationMark.swiftUIImage
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.phase {
        case .idle:
            idleBlock
        case .creating:
            creatingBlock
        case .success:
            successBlock
        case .failure:
            failureBlock
        }
    }
    
    private var idleBlock: some View {
        Text(String(localized: "onboarding.keys.description"))
            .font(PQFont.R14)
            .foregroundStyle(PQColor.blue2.swiftUIColor)
            .multilineTextAlignment(.center)
    }
    
    private var creatingBlock: some View {
        VStack(spacing: 8) {
            ProgressView(value: viewModel.progress, total: 1.0)
                .tint(PQColor.blue6.swiftUIColor)
                .frame(height: 6)
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                )
            
            Text(viewModel.status.text)
                .font(PQFont.R14)
                .foregroundStyle(PQColor.blue2.swiftUIColor)
                .multilineTextAlignment(.center)
        }
        .transition(.opacity)
        .animation(.easeInOut, value: viewModel.status)
    }
    
    private var successBlock: some View {
        Text(String(localized: "onboarding.keys.success.description"))
            .font(PQFont.R14)
            .foregroundStyle(PQColor.blue2.swiftUIColor)
            .multilineTextAlignment(.center)
    }
    
    private var failureBlock: some View {
        Text(String(localized: "onboarding.keys.failure.description"))
            .font(PQFont.R14)
            .foregroundStyle(PQColor.blue2.swiftUIColor)
            .multilineTextAlignment(.center)
    }
    
    @ViewBuilder
    private var bottomButton: some View {
        switch viewModel.phase {
        case .idle:
            PQButton(String(localized: "onboarding.keys.generate")) {
                viewModel.createKeys()
            }
        case .creating:
            EmptyView()
        case .success:
            PQButton(
                String(localized: "shared.next"),
                action: viewModel.finish
            )
        case .failure:
            PQButton(String(localized: "shared.retry"), action: viewModel.retry)
        }
    }
    
    // MARK: - Initializer
    
    init(viewModel: CreateKeysViewModel) {
        self.viewModel = viewModel
    }
}
