//
//  Contact.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 28.02.2026.
//

import Foundation
import PQContainerKit

struct Contact: Identifiable {
    let id: UUID
    var name: String
    var isVerified: Bool
    let publicKeyRaw: Data
    var fingerprint: String {
        Fingerprint.fromPublicKeyRaw(publicKeyRaw).hexStringGrouped
    }
}
