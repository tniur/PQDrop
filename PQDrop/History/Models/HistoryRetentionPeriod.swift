//
//  HistoryRetentionPeriod.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 15.04.2026.
//

enum HistoryRetentionPeriod: Int, CaseIterable, Identifiable {
    case ninety = 90
    case thirty = 30
    case seven = 7

    var id: Int { rawValue }

    var title: String {
        "\(rawValue) дней"
    }
}
