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
            Text("Фильтры")
                .font(PQFont.B30)
                .foregroundStyle(PQColor.base7.swiftUIColor)
            
            VStack(spacing: 16) {
                ForEach(ContactsFilter.allCases) { filter in
                    HStack {
                        Text(filter.rawValue)
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
        .padding()
        .presentationDetents([.height(230)])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Initializer

    init(model: ContactsFilterSheetModel) {
        self.model = model
    }
}
