//
//  RecipientsSheetView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 22.03.2026.
//

import SwiftUI
import PQUIComponents

struct RecipientsSheetView: View {
    
    // MARK: - Properties

    private let recipients: [Recipient]

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Получатели")
                .font(PQFont.B24)
                .foregroundStyle(PQColor.base7.swiftUIColor)
                .padding(.top, 20)

            if recipients.isEmpty {
                emptyView
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(recipients) { recipient in
                            RecipientRowView(
                                name: recipient.name,
                                shortKey: recipient.shortFingerprint,
                                isVerified: recipient.isVerified
                            )
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
        }
        .padding(.horizontal, 20)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Subviews

    private var emptyView: some View {
        VStack {
            Spacer()
            Text("Получателей пока нет. Доступ есть только у вас.")
                .font(PQFont.R16)
                .foregroundStyle(PQColor.base5.swiftUIColor)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
    
    // MARK: - Initializer

    init(recipients: [Recipient]) {
        self.recipients = recipients
    }
}
