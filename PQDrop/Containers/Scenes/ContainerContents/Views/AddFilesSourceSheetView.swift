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
            Text("Добавить файлы")
                .font(PQFont.B24)
                .foregroundStyle(PQColor.base7.swiftUIColor)
                .padding(.top, 20)
            VStack(alignment: .leading, spacing: 4) {
                PQButton(
                    "Из файлов",
                    icon: PQImage.doc.swiftUIImage,
                    action: onFilesTap
                )
                
                PQButton(
                    "Из галереи",
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
