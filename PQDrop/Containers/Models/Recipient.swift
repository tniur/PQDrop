//
//  Recipient.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 22.03.2026.
//

import Foundation

struct Recipient: Identifiable {
    let id: String
    let name: String
    let publicKey: String
    let isVerified: Bool

    var shortKey: String {
        guard publicKey.count > 7 else { return publicKey }
        return "\(publicKey.prefix(4))...\(publicKey.suffix(3))"
    }
}
