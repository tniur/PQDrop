//
//  IconTextLabel.swift
//  PQUIComponents
//
//  Created by Анастасия Журавлева on 22.03.2026.
//

import SwiftUI

public struct IconTextLabel: View {

    @Environment(\.isEnabled) private var isEnabled

    private let title: String?
    private let localizedTitle: LocalizedStringKey?
    private let icon: Image
    private let style: PQButtonStyle
    
    private var foregroundStyle: Color {
        if isEnabled {
            style.type.iconColor
        } else {
            style.type.disabledIconColor
        }
    }
    
    public var body: some View {
        HStack(spacing: 4) {
            icon
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(foregroundStyle)
                .frame(width: 24, height: 24)
            if let title {
                Text(title)
            } else if let localizedTitle {
                Text(localizedTitle)
            }
        }
    }

    init(title: String, icon: Image, style: PQButtonStyle) {
        self.title = title
        self.localizedTitle = nil
        self.icon = icon
        self.style = style
    }

    init(localizedTitle: LocalizedStringKey, icon: Image, style: PQButtonStyle) {
        self.title = nil
        self.localizedTitle = localizedTitle
        self.icon = icon
        self.style = style
    }
}
