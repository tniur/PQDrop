//
//  AddFilesSourceSheetView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 08.04.2026.
//

import SwiftUI
import PQUIComponents

struct AddFilesSourceSheetView: View {

    let onFilesTap: () -> Void
    let onGalleryTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(localized: "shared.add.files"))
                .font(PQFont.B24)
                .foregroundStyle(PQColor.base7.swiftUIColor)
                .padding(.top, 20)
            VStack(alignment: .leading, spacing: 4) {
                PQButton(
                    String(localized: "files.source.files"),
                    icon: PQImage.doc.swiftUIImage,
                    action: onFilesTap
                )
                
                PQButton(
                    String(localized: "files.source.gallery"),
                    icon: PQImage.photo.swiftUIImage,
                    action: onGalleryTap
                )
            }
        }
        .padding(.horizontal, 20)
        .presentationDetents([.height(200)])
        .presentationDragIndicator(.visible)
    }
}
