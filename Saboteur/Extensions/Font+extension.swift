//
//  Font+extension.swift
//  Saboteur
//
//  Created by Baba on 7/22/25.
//

import SwiftUI

// MARK: - Custom Font Namespace
enum CustomFont {
    static func largeTitle(size: CGFloat, weight: Font.Weight = .black) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    static func title1(size: CGFloat, weight: Font.Weight = .black) -> Font {
        .custom("MaplestoryOTFBold", size: size)
    }

    static func title2(size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .custom("MaplestoryOTFBold", size: size)
    }

    static func body1(size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .custom("MaplestoryOTFBold", size: size)
    }

    static func body2(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("MaplestoryOTFBold", size: size)
    }

    static func body2Wide(size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .custom("MaplestoryOTFBold", size: size)
    }

    static func label1(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("MaplestoryOTFBold", size: size)
    }

    static func label2(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("MaplestoryOTFBold", size: size)
    }

    static func label3(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("MaplestoryOTFBold", size: size)
    }

    static func label4(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("MaplestoryOTFBold", size: size)
    }

    static func label5(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("MaplestoryOTFBold", size: size)
    }
}

// Optional shorthand
typealias CF = CustomFont

// MARK: - View Extension for Font Modifiers
extension View {
    func largeTitleFont(size: CGFloat = 48, kerningPercentage: CGFloat? = 0.10) -> some View {
        self.font(CustomFont.largeTitle(size: size))
            .kerning((kerningPercentage ?? 0.0) * size)
    }

    func title1Font(size: CGFloat = 33, kerningPercentage: CGFloat? = 0.0) -> some View {
        self.font(CustomFont.title1(size: size))
            .kerning((kerningPercentage ?? 0.0) * size)
    }

    func title2Font(size: CGFloat = 23, kerningPercentage: CGFloat? = 0.05) -> some View {
        self.font(CustomFont.title2(size: size))
            .kerning((kerningPercentage ?? 0.0) * size)
    }

    func body1Font(size: CGFloat = 21, kerningPercentage: CGFloat? = 0.05) -> some View {
        self.font(CustomFont.body1(size: size))
            .kerning((kerningPercentage ?? 0.0) * size)
    }

    func body2Font(size: CGFloat = 20, kerningPercentage: CGFloat? = 0.0) -> some View {
        self.font(CustomFont.body2(size: size))
            .kerning((kerningPercentage ?? 0.0) * size)
    }

    func body2WideFont(size: CGFloat = 20, kerningPercentage: CGFloat? = 0.05) -> some View {
        self.font(CustomFont.body2Wide(size: size))
            .kerning((kerningPercentage ?? 0.0) * size)
    }

    func label1Font(size: CGFloat = 16, kerningPercentage: CGFloat? = 0.0) -> some View {
        self.font(CustomFont.label1(size: size))
            .kerning((kerningPercentage ?? 0.0) * size)
    }

    func label2Font(size: CGFloat = 14, kerningPercentage: CGFloat? = 0.0) -> some View {
        self.font(CustomFont.label2(size: size))
            .kerning((kerningPercentage ?? 0.0) * size)
    }

    func label3Font(size: CGFloat = 13, kerningPercentage: CGFloat? = 0.05) -> some View {
        self.font(CustomFont.label3(size: size))
            .kerning((kerningPercentage ?? 0.0) * size)
    }

    func label4Font(size: CGFloat = 12, kerningPercentage: CGFloat? = 0.0) -> some View {
        self.font(CustomFont.label4(size: size))
            .kerning((kerningPercentage ?? 0.0) * size)
    }

    func label5Font(size: CGFloat = 10, kerningPercentage: CGFloat? = 0.0) -> some View {
        self.font(CustomFont.label5(size: size))
            .kerning((kerningPercentage ?? 0.0) * size)
    }
}
