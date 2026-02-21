import SwiftUI

struct TopBar: View {

    @Binding var showBudgetPopup: Bool
    @Binding var showInterestPopup: Bool

    let selectedBudget: Int?
    let hasActiveInterests: Bool

    @Binding var selectedInterests: Set<Interest>
    var onDoneCategories: () -> Void

    // 🔥 مهم
    @Binding var searchText: String
    var onSearchSubmit: (String) -> Void

    @FocusState private var isSearchFocused: Bool

    var body: some View {
        VStack(spacing: 10) {

            // SEARCH BAR
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.green)

                TextField("Search", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .submitLabel(.search)
                    .focused($isSearchFocused)
                    .onSubmit {
                        onSearchSubmit(searchText)   // 🔥 هذا اللي كان ناقص
                        isSearchFocused = false
                    }

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Image(systemName: "person.crop.circle")
                    .font(.system(size: 22))
                    .foregroundStyle(.gray)
            }
            .padding(.horizontal, 14)
            .frame(height: 52)
            .background(Color.white.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 14)
            .padding(.top, 6)

            // FILTERS
            HStack(spacing: 10) {

                Button {
                    withAnimation { showBudgetPopup.toggle() }
                    if showBudgetPopup { showInterestPopup = false }
                } label: {
                    HStack(spacing: 8) {
                        Image(selectedBudgetImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)

                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.black.opacity(0.6))
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 36)
                    .background(Color(hex: "#CCADD9").opacity(0.65))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button {
                    withAnimation { showInterestPopup.toggle() }
                    if showInterestPopup { showBudgetPopup = false }
                } label: {
                    HStack(spacing: 8) {
                        Text("Categories")
                            .font(.system(size: 14, weight: .medium))

                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 36)
                    .background(Color(hex: "#CCADD9").opacity(hasActiveInterests ? 0.65 : 0.35))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .popover(isPresented: $showInterestPopup) {
                    CategoriesPopup(selectedInterests: $selectedInterests) {
                        onDoneCategories()
                    }
                    .padding(8)
                    .presentationCompactAdaptation(.none)
                }

                Spacer()
            }
            .padding(.horizontal, 14)
        }
    }

    private var selectedBudgetImageName: String {
        "budget\(selectedBudget ?? 1)"
    }
}
