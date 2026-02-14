import SwiftUI

struct PlacesNearYouSheet: View {
    let title: String
    @Binding var isExpanded: Bool
    let places: [Place]
    var onSearchHere: () -> Void

    var body: some View {
        VStack(spacing: 12) {

            Capsule()
                .fill(Color.black.opacity(0.12))
                .frame(width: 52, height: 5)
                .padding(.top, 10)

            HStack {
                Text(title)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.black.opacity(0.9))
                Spacer()
            }
            .padding(.horizontal, 18)

            if isExpanded {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(places.prefix(8)) { p in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(p.name)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.black.opacity(0.85))

                                    Text(p.interest.title)
                                        .font(.system(size: 12))
                                        .foregroundColor(.black.opacity(0.45))
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.18))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(.horizontal, 18)
                }
                .frame(height: 140)
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .padding(.horizontal, 14)
        // 👇 نخلي مسافة للتاب بار
        
        .onTapGesture {
            withAnimation(.easeInOut) { isExpanded.toggle() }
        }
    }
}
