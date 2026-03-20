//
//  BackgroundView.swift
//  PQUIComponents
//
//  Created by Анастасия Журавлева on 16.02.2026.
//

import SwiftUI

public struct BackgroundView<Content: View>: View {

    // MARK: - Properties

    private let isImage: Bool
    private let content: () -> Content

    // MARK: - Body

    public var body: some View {
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundView)
    }

    // MARK: - Subviews

    @ViewBuilder
    private var backgroundView: some View {
        if isImage {
            PQImage.background.swiftUIImage
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .padding(-10)
        } else {
            PQColor.base1.swiftUIColor
                .ignoresSafeArea()
        }
    }

    // MARK: - Initializer

    public init(
        isImage: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.isImage = isImage
        self.content = content
    }
}
