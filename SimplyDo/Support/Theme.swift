//
//  Theme.swift
//  SimplyDo
//

import SwiftUI

enum AppColor {
    static let background = Color("AppBackground")
    static let card: Material = .regularMaterial
    static let row = Color("RowBackground")
    static let rowHover = Color("RowBackgroundHover")
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
    static let accent = Color.accentColor
}

enum Metrics {
    static let popoverWidth: CGFloat = 400
    static let maxListHeight: CGFloat = 480
    static let cardCornerRadius: CGFloat = 18
    static let rowCornerRadius: CGFloat = 12
    static let cardPadding: CGFloat = 14
    static let cardContentSpacing: CGFloat = 8
    static let cardSpacing: CGFloat = 12
    static let contentInset: CGFloat = 16
    static let checkboxTapTarget: CGFloat = 22
}
