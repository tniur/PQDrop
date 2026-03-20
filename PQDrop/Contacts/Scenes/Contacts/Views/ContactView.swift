//
//  ContactView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 28.02.2026.
//

import SwiftUI
import PQUIComponents

struct ContactView: View {
    
    // MARK: - Properties

    private let name: String
    private let isVerified: Bool
    
    private var markIcon: Image {
        isVerified ? PQImage.done.swiftUIImage : PQImage.xmark.swiftUIImage
    }
    
    private var markText: String {
        isVerified ? "Verified" : "Unverified"
    }
    
    private var markBackgroundColor: Color {
        isVerified ? PQColor.green5.swiftUIColor : PQColor.base4.swiftUIColor
    }
    
    // MARK: - Body

    var body: some View {
        HStack {
            Text(name)
                .font(PQFont.B14)
                .foregroundStyle(PQColor.base10.swiftUIColor)
            
            Spacer()

            isVerifiedView
        }
        .padding(.vertical)
        .padding(.horizontal, 20)
        .background(
            Capsule()
                .foregroundStyle(PQColor.base0.swiftUIColor)
        )
    }

    // MARK: - Subviews

    private var isVerifiedView: some View {
        HStack(spacing: 2) {
            markIcon
                .renderingMode(.template)
                .foregroundStyle(PQColor.base0.swiftUIColor)
            
            Text(markText)
                .font(PQFont.B12)
                .foregroundStyle(PQColor.base0.swiftUIColor)
        }
        .padding(8)
        .background(
            Capsule()
                .foregroundStyle(markBackgroundColor)
        )
    }
    
    // MARK: - Initializer

    init(name: String, isVerified: Bool) {
        self.name = name
        self.isVerified = isVerified
    }
}
