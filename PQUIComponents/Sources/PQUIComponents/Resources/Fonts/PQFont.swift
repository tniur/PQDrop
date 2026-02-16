//
//  PQFont.swift
//  PQUIComponents
//
//  Created by Анастасия Журавлева on 16.02.2026.
//

import SwiftUI
import UIKit

public enum PQFont {
    public static let B30 = Font.system(size: 30, weight: .bold)
    public static let B16 = Font.system(size: 16, weight: .bold)
    public static let B14 = Font.system(size: 14, weight: .bold)
    public static let B12 = Font.system(size: 12, weight: .bold)

    public static let M20 = Font.system(size: 20, weight: .medium)

    public static let R16 = Font.system(size: 16, weight: .regular)
    public static let R14 = Font.system(size: 14, weight: .regular)
    public static let R12 = Font.system(size: 12, weight: .regular)

    public static let I16 = Font.system(size: 16, weight: .regular).italic()
    public static let I14 = Font.system(size: 14, weight: .regular).italic()
    public static let I12 = Font.system(size: 12, weight: .regular).italic()
}
