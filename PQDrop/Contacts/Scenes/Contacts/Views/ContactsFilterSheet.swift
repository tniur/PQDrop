//
//  ContactsFilterSheet.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 01.03.2026.
//

import SwiftUI
import PQUIComponents

struct ContactsFilterSheet: View {
    
    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss

    private let model: ContactsFilterSheetModel
        
    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(String(localized: "contacts.filters.title"))
                .font(PQFont.B24)
                .foregroundStyle(PQColor.base7.swiftUIColor)
                .padding(.top, 20)

            VStack(spacing: 16) {
                ForEach(ContactsFilter.allCases) { filter in
                    HStack {
                        Text(filter.title)
                            .font(PQFont.B16)
                            .foregroundStyle(PQColor.base7.swiftUIColor)
                        
                        Spacer()
                        
                        if model.currentFilter == filter {
                            PQImage.done.swiftUIImage
                                .renderingMode(.template)
                                .foregroundStyle(PQColor.base7.swiftUIColor)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        model.onFilterChange(filter)
                        dismiss()
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .presentationDetents([.height(160)])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Initializer

    init(model: ContactsFilterSheetModel) {
        self.model = model
    }
}
