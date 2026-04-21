//
//  OnboardingView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 17.02.2026.
//

import SwiftUI
import PQUIComponents

struct OnboardingView: View {
    
    // MARK: - Properties

    @ObservedObject private var viewModel: OnboardingViewModel
    
    // MARK: - Body

    var body: some View {
        BackgroundView(isImage: true) {
            ZStack(alignment: .bottom) {
                TabView(selection: $viewModel.index) {
                    ForEach(viewModel.steps) { step in
                        OnboardingPage(step: step)
                            .tag(step.id)
                            .padding(.top, 60)
                            .padding(.horizontal)
                    }
                }
                
                VStack(spacing: 8) {
                    PQButton(
                        viewModel.isLast ? String(localized: "onboarding.create.keys") : String(localized: "shared.next"),
                        action: viewModel.topButtonAction
                    )
                    
                    PQButton(
                        viewModel.isFirst ? String(localized: "shared.skip") : String(localized: "shared.back"),
                        style: PQButtonStyle(.tertiary),
                        action: viewModel.bottomButtonAction
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .overlayPreferenceValue(IconAnchorKey.self) { anchors in
                GeometryReader { proxy in
                    if let anchor = anchors[viewModel.index] {
                        let rect = proxy[anchor]
                        
                        PageControl(
                            currentPage: $viewModel.index,
                            numberOfPages: viewModel.steps.count
                        )
                        .frame(width: 72, height: 8)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                        )
                        .position(
                            x: proxy.size.width / 2,
                            y: rect.maxY + 8
                        )
                        .allowsHitTesting(false)
                    }
                }
            }
        }
    }

    // MARK: - Initializer

    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
    }
}
