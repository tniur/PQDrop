//
//  ProfileView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 27.02.2026.
//

import SwiftUI

struct ProfileView: View {
    
    // MARK: - Properties

    @ObservedObject private var viewModel: ProfileViewModel
    
    // MARK: - Body

    var body: some View {
        Text("profile.title")
    }
    
    // MARK: - Initializer

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
    }
}
