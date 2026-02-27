//
//  BackgroundView.swift
//  PQUIComponents
//
//  Created by Анастасия Журавлева on 16.02.2026.
//

import SwiftUI

public struct BackgroundView<Content: View>: View {
    let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        content()
            .background(
                PQImage.background.swiftUIImage
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .padding(-10)
            )
    }
}
