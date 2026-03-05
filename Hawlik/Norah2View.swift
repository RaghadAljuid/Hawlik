import SwiftUI

struct Norah2View: View {
    @ObservedObject var viewModel: TripViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()

            VStack(spacing: 18) {

                // Top Bar
                HStack {
                    Button { dismiss() } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.white.opacity(0.95))
                    }
                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)

                Spacer()

                // 1) يفتح صفحة اختيار الأماكن
                NavigationLink {
                    SelectPlacesView(viewModel: viewModel)
                } label: {
                    Text("Select Places")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                        .frame(maxWidth: .infinity, minHeight: 54)
                        .background(Color.white.opacity(0.20))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .padding(.horizontal, 22)

                // 2) يفتح صفحة الأماكن المحفوظة
                NavigationLink {
                    TripPlacesView(viewModel: viewModel)
                } label: {
                    Text("Your Trip Places")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                        .frame(maxWidth: .infinity, minHeight: 54)
                        .background(Color.white.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .padding(.horizontal, 22)

                Spacer()
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}
