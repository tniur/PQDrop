//
//  SplashView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 16.02.2026.
//

import SwiftUI
import PQUIComponents

struct SplashView: View {
    
    // MARK: - Properties

    @ObservedObject private var viewModel: SplashViewModel
    
    // MARK: - Body

    var body: some View {
        BackgroundView(isImage: true) {
            Text("PQDrop")
                .font(PQFont.B30)
                .foregroundStyle(PQColor.base0.swiftUIColor)
                .onAppear(perform: viewModel.onAppear)
        }
    }
    
    // MARK: - Initializer

    init(viewModel: SplashViewModel) {
        self.viewModel = viewModel
    }
}
