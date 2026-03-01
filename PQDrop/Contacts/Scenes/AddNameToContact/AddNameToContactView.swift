//
//  AddNameToContactView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 01.03.2026.
//

import SwiftUI

struct AddNameToContactView : View {
    
    // MARK: - Properties

    @ObservedObject private var viewModel: AddNameToContactViewModel
    
    // MARK: - Body

    var body: some View {
        Text("name")
    }
    
    // MARK: - Initializer

    init(viewModel: AddNameToContactViewModel) {
        self.viewModel = viewModel
    }
}
