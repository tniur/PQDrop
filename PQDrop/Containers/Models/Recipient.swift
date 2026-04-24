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
    let fingerprint: String
    let isVerified: Bool
    let isManageable: Bool

    var shortFingerprint: String {
        guard fingerprint.count > 16 else { return fingerprint }
        return "\(fingerprint.prefix(8))...\(fingerprint.suffix(8))"
    }
}
