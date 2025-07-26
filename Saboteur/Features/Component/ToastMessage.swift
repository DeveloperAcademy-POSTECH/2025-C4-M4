import SwiftUI

struct ToastMessage<T: Equatable>: View {
    let message: String
    let animationTrigger: T

    var body: some View {
        VStack {
            Text(message)
                .foregroundStyle(Color.Grayscale.white)
                .label2Font()
                .padding(.vertical, 10)
                .padding(.horizontal, 64)
                .background(Color.black.opacity(0.5))
                .cornerRadius(30)
                .transition(.move(edge: .top).combined(with: .opacity))
            Spacer()
        }
        .padding(.top, 24)
        .animation(.easeInOut, value: animationTrigger)
    }
}
