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
        VStack(alignment: .leading, spacing: 8) {
            Text("Добавить файлы")
                .font(PQFont.B24)
                .foregroundStyle(PQColor.base7.swiftUIColor)

            PQButton(
                "Из файлов",
                icon: Image(systemName: "folder"),
                style: .init(.purple),
                action: onFilesTap
            )

            PQButton(
                "Из галереи",
                icon: Image(systemName: "photo.on.rectangle"),
                style: .init(.purple),
                action: onGalleryTap
            )

            Spacer()
        }
        .padding(20)
        .presentationDetents([.height(200)])
        .presentationDragIndicator(.visible)
    }
}
