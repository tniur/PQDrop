//
//  IconAnchorKey.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 18.02.2026.
//

import SwiftUI

struct IconAnchorKey: PreferenceKey {
    static var defaultValue: [Int: Anchor<CGRect>] = [:]
    static func reduce(value: inout [Int: Anchor<CGRect>], nextValue: () -> [Int: Anchor<CGRect>]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}
