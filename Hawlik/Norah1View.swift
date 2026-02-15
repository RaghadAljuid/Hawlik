//
//  Norah1View.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 27/08/1447 AH.
//
import SwiftUI

struct Norah1View: View {
    @ObservedObject var viewModel: TripViewModel
    var onClose: () -> Void

    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()

            VStack {
                HStack {
                    Button(action: onClose) {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                Spacer()

                VStack(spacing: 12) {
                    Text("Plan Your Trip ✈️")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.5))
                        .bold()

                    Text("Everything you need, all in one place")
                        .font(.system(size: 19))
                        .foregroundColor(.white.opacity(0.5))
                        .bold()
                }

                Spacer()

                NavigationLink {
                    Norah2View(viewModel: viewModel)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 60, weight: .light))
                        .foregroundColor(.white.opacity(0.4))
                        .frame(width: 60, height: 60)
                        .overlay(Circle().stroke(Color.purple.opacity(0.5), lineWidth: 1))
                        .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
                        .glassEffect()
                }
                .padding(.bottom, 60)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}
