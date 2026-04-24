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

    var containerIDHex: String {
        containerID.map { String(format: "%02x", $0) }.joined()
    }

    var shortContainerID: String {
        guard containerIDHex.count > 12 else {
            return containerIDHex
        }

        return "\(containerIDHex.prefix(6))...\(containerIDHex.suffix(6))"
    }
}
