//
//  FileCardView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 08.04.2026.
//

import SwiftUI
import PQUIComponents

struct FileCardView: View {

    let file: ContainerFileItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .bottom) {
                previewView

                if file.isDraftAdded {
                    badge(title: "Новый", color: PQColor.green6.swiftUIColor)
                        .padding(6)
                }

                if file.isMarkedForDeletion {
                    badge(title: "Будет удалён", color: PQColor.red6.swiftUIColor)
                        .padding(6)
                }
            }

            Text(file.name)
                .font(PQFont.R14)
                .foregroundStyle(PQColor.base0.swiftUIColor)
                .lineLimit(1)

            Text(file.sizeText)
                .font(PQFont.R12)
                .foregroundStyle(PQColor.blue2.swiftUIColor)
        }
    }

    private var previewView: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(PQColor.base0.swiftUIColor)
            .frame(height: 141)
            .overlay {
                VStack(spacing: 8) {
                    Image(systemName: "doc.richtext")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(PQColor.blue6.swiftUIColor)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.20))
                        .frame(height: 5)
                        .padding(.horizontal, 18)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.16))
                        .frame(height: 5)
                        .padding(.horizontal, 18)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.12))
                        .frame(height: 5)
                        .padding(.horizontal, 26)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        file.isMarkedForDeletion ? PQColor.red6.swiftUIColor : Color.clear,
                        lineWidth: 1
                    )
            )
    }

    private func badge(title: String, color: Color) -> some View {
        Text(title)
            .font(PQFont.R12)
            .foregroundStyle(PQColor.base0.swiftUIColor)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(color)
            )
    }
}
