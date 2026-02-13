import SwiftUI

struct AppBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 48/255, green: 25/255, blue: 52/255),
                    Color(red: 72/255, green: 45/255, blue: 103/255),
                    Color(red: 37/255, green: 23/255, blue: 77/255)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.white.opacity(0.02), location: 0),
                    .init(color: Color.black.opacity(0.05), location: 0.5),
                    .init(color: Color.white.opacity(0.02), location: 1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blendMode(.overlay)
            .ignoresSafeArea()

            NoiseOverlay()
                .blendMode(.overlay)
                .ignoresSafeArea()
        }
    }
}

fileprivate struct NoiseOverlay: View {
    private let noiseImage: Image = {
        // Generate a small noise pattern and tile it
        let size = CGSize(width: 64, height: 64)
        let renderer = UIGraphicsImageRenderer(size: size)
        let uiImage = renderer.image { context in
            let cgContext = context.cgContext
            cgContext.setFillColor(UIColor.clear.cgColor)
            cgContext.fill(CGRect(origin: .zero, size: size))

            for _ in 0..<Int(size.width * size.height / 10) {
                let x = CGFloat.random(in: 0..<size.width)
                let y = CGFloat.random(in: 0..<size.height)
                let alpha = CGFloat.random(in: 0.02...0.06)
                cgContext.setFillColor(UIColor(white: 1, alpha: alpha).cgColor)
                cgContext.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }
        return Image(uiImage: uiImage)
    }()

    var body: some View {
        noiseImage
            .resizable(resizingMode: .tile)
            .opacity(0.12)
    }
}
