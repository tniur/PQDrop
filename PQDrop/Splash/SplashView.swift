//
//  SplashView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 16.02.2026.
//

import SwiftUI
import PQUIComponents

struct SplashView: View {
    
    @ObservedObject private var viewModel: SplashViewModel
    
    var body: some View {
        BackgroundView {
            Text("PQDrop")
                .font(PQFont.B30)
                .foregroundStyle(PQColor.base0.swiftUIColor)
        }
    }
    
    init(viewModel: SplashViewModel) {
        self.viewModel = viewModel
    }
}
