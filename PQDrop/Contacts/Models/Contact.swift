//
//  Contact.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 28.02.2026.
//

import Foundation

struct Contact: Identifiable {
    let id: String
    var name: String
    var isVerified: Bool
    let fingerprint: String
}
