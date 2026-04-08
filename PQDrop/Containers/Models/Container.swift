//
//  Container.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 20.03.2026.
//

import Foundation

struct Container: Identifiable {
    let id: String
    var name: String
    var isAvailable: Bool
    var isCreated: Bool
    var files: [ContainerFileItem] = []
}
