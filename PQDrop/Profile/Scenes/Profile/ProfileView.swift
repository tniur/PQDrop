//
//  ProfileView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 27.02.2026.
//

import SwiftUI

struct ProfileView: View {
    
    @ObservedObject private var viewModel: ProfileViewModel
    
    var body: some View {
        Text("Профиль")
    }
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
    }
}
