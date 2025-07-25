//
//  Practice.swift
//  Saboteur
//
//  Created by 이주현 on 7/25/25.
//

import SwiftUI

struct Practice: View {
    var body: some View {
        // 내 차례
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Image(.koreaIcon)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .stroke(Color.Emerald.emerald1, lineWidth: 2)
                    )

                Spacer()

                HStack(spacing: 1) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 10))

                    Text("1:30")
                }
                .foregroundStyle(Color.Grayscale.whiteBg)
                .label4Font()
                .padding(.vertical, 2)
                .padding(.leading, 3)
                .padding(.trailing, 7)
                .background {
                    RoundedRectangle(cornerRadius: 4)
                        .foregroundStyle(Color.Etc.pink)
                }
            }

            Text("WWWWWWWW")
                .foregroundStyle(Color.Ivory.ivory1)
                .label5Font()
                .padding(.horizontal, 4)
                .padding(.top, 1)
                .padding(.bottom, 5)
                .background(
                    RoundedRectangle(cornerRadius: 3.3)
                        .shadow4ColorInner(color: Color.Emerald.emerald1)
                        .foregroundStyle(Color.Emerald.emerald3)
                        .overlay(content: {
                            RoundedRectangle(cornerRadius: 3.3)
                                .stroke(Color.Emerald.emerald1, lineWidth: 1)
                        })
                )
        }
        .frame(width: 86, height: 39)

        // 다른 사람
        VStack(alignment: .leading, spacing: 3) {
            Image(.koreaIcon)
                .resizable()
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .stroke(Color.Ivory.ivory2, lineWidth: 2)
                )

            Text("WWWWWWWW")
                .foregroundStyle(Color.Emerald.emerald1)
                .label5Font()
                .padding(.horizontal, 4)
                .padding(.top, 1)
                .padding(.bottom, 5)
                .background(
                    RoundedRectangle(cornerRadius: 3.3)
                        .shadow4ColorInner(color: Color.Ivory.ivory2)
                        .foregroundStyle(Color.Ivory.ivory1)
                        .overlay(content: {
                            RoundedRectangle(cornerRadius: 3.3)
                                .stroke(Color.Ivory.ivory2, lineWidth: 1)
                        })
                )
        }
    }
}

#Preview {
    Practice()
}
