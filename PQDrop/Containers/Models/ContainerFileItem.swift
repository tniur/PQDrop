//
//  ContainerFileItem.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 08.04.2026.
//

import Foundation

struct ContainerFileItem: Identifiable, Equatable {
    let id: String
    var name: String
    var sizeText: String
    var isDraftAdded: Bool = false
    var isMarkedForDeletion: Bool = false
}
