//
//  OutButton .swift
//  Saboteur
//
//  Created by 이주현 on 7/25/25.
//

import SwiftUI

struct OutButton: View {
    let action: () -> Void
    let image: Image
    let activeColor: Color
    let isDisabled: Bool?
    var imageWidth: CGFloat?

    init(
        action: @escaping () -> Void,
        image: Image,
        activeColor: Color,
        isDisabled: Bool? = nil,
        imageWidth: CGFloat? = nil
    ) {
        self.action = action
        self.image = image
        self.activeColor = activeColor
        self.isDisabled = isDisabled
        self.imageWidth = imageWidth
    }

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 100)
                    .innerShadow()
                    .foregroundStyle((isDisabled ?? false) ? Color.Grayscale.gray : activeColor)
                    .frame(width: 62, height: 50)

                if let width = imageWidth {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageWidth)
                } else {
                    image
                }
            }
        }
        .disabled(isDisabled ?? false)
    }
}

struct OutButtonPreview: View {
    var body: some View {
        OutButton(
            action: {},
            image: Image(.xButton),
            activeColor: Color.Emerald.emerald2,
            isDisabled: nil
        )
    }
}

#Preview {
    OutButtonPreview()
}
