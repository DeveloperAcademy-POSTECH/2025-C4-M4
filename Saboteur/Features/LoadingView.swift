import Lottie
import SwiftUI

struct LottieView: UIViewRepresentable {
    let filename: String

    func makeUIView(context _: Context) -> UIView {
        let container = UIView()
        let animationView = LottieAnimationView(name: filename)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.clipsToBounds = true
        animationView.loopMode = .loop
        animationView.play()

        container.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: container.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        return container
    }

    func updateUIView(_: UIViewType, context _: Context) {}
}

struct LoadingView: View {
    @State private var displayedText = ""
    @State private var currentIndex = 0
    let fullText = "Loading..."
    let animationInterval = 0.3

    var timer: Timer?

    var body: some View {
        ZStack {
            Image(.background)
                .resizable()
                .ignoresSafeArea()

            LottieView(filename: "LoadingAnimation")
                .frame(width: 500, height: 300)
                .padding(.bottom, -20)

            VStack {
                Spacer()

                Text(displayedText)
                    .body2Font()
                    .foregroundStyle(Color.Emerald.emerald1)
                    .onAppear {
                        Timer.scheduledTimer(withTimeInterval: animationInterval, repeats: true) { _ in
                            if currentIndex < fullText.count {
                                let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
                                displayedText.append(fullText[index])
                                currentIndex += 1
                            } else {
                                displayedText = ""
                                currentIndex = 0
                            }
                        }
                    }
            }
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    LoadingView()
}
