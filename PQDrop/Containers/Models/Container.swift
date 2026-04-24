//
//  Container.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 20.03.2026.
//

import Foundation

struct Container: Identifiable {
    let id: UUID
    let containerID: Data
    var recipientPublicKeysRaw: [Data] = []
    var name: String
    var fileURL: URL?
    var isAvailable: Bool
    var isOwned: Bool
    var files: [ContainerFileItem] = []
}
