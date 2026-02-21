//
//  TopBar.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 20/08/1447 AH.
//
import SwiftUI

struct TopBar: View {
    @Binding var showBudgetPopup: Bool
    @Binding var showInterestPopup: Bool

    let selectedBudget: Int?
    let hasActiveInterests: Bool

    // ✅ جديد
    @Binding var selectedInterests: Set<Interest>
    var onDoneCategories: () -> Void

    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 10) {

            // Search bar (واجهة فقط الآن)
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.green)

                TextField("Search", text: $searchText)
                    .textInputAutocapitalization(.never)

                Spacer()

                Button {
                    // TODO: افتح صفحة الحساب لاحقًا
                    print("Account tapped")
                } label: {
////                    Image(systemName: "person.crop.circle")
//                        .font(.system(size: 22))
//                        .foregroundStyle(.gray)
//                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

            }
            .padding(.horizontal, 14)
            .frame(height: 52)
            .background(Color.white.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 14)
            .padding(.top, 6)

            // Row: Budget + Interests
            HStack(spacing: 10) {

                // ✅ Budget button
                Button {
                    withAnimation(.easeInOut) { showBudgetPopup.toggle() }
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
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)

                // ✅ Categories button + POPUP صغير تحت الزر
                Button {
                    withAnimation(.easeInOut) { showInterestPopup.toggle() }
                    if showInterestPopup { showBudgetPopup = false }
                } label: {
                    HStack(spacing: 8) {
                        Text("Categories")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.black.opacity(0.8))

                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.black.opacity(0.6))
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 36)
                    .background(Color(hex: "#CCADD9").opacity(hasActiveInterests ? 0.65 : 0.35))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showInterestPopup,
                         attachmentAnchor: .rect(.bounds),
                         arrowEdge: .top) {

                    CategoriesPopup(selectedInterests: $selectedInterests) {
                        onDoneCategories()
                    }
                    .padding(8)
                    .presentationCompactAdaptation(.none) // ✅ يخليه Popup مو Sheet على iPhone
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
