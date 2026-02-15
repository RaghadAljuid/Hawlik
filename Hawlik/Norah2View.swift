//
//  Norah2View.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 27/08/1447 AH.
//
import SwiftUI

struct Norah2View: View {
    @ObservedObject var viewModel: TripViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()

            VStack {
                HStack {
                    Button(action: { dismiss() }) {
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

                VStack(alignment: .leading, spacing: 25) {

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Your Budget")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .semibold))

                        Picker("Select", selection: $viewModel.preference.budget) {
                            Text("Select").tag("")
                            ForEach(viewModel.budgetImages, id: \.self) { imageName in
                                Image(imageName)
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .tag(imageName)
                            }
                        }
                        .pickerStyle(.menu)
                        .modifier(GlassFieldStyle())
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Your Interest")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .semibold))
                            .bold()

                        Picker("Select", selection: $viewModel.preference.interest) {
                            Text("Select").tag("")
                            ForEach(viewModel.interestOptions, id: \.self) { interest in
                                Text(interest).tag(interest)
                            }
                        }
                        .pickerStyle(.menu)
                        .modifier(GlassFieldStyle())
                    }

                    NavigationLink(destination: SelectPlacesView(viewModel: viewModel)) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                Color(red: 106/255, green: 109/255, blue: 255/255).opacity(0.6)
                            )
                            .cornerRadius(25)
                            .glassEffect()
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        viewModel.continuePlanning()
                    })
                    .padding(.top, 10)
                }
                .padding(30)
                .background(Color.black.opacity(0.4))
                .cornerRadius(30)
                .padding(.horizontal, 25)

                Spacer()
            }
            .padding(.bottom, 20)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        Norah2View(viewModel: TripViewModel())
    }
}
