//
//  TripPlacesView.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 27/08/1447 AH.
//
import SwiftUI

struct TripPlacesView: View {

    @ObservedObject var viewModel: TripViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {

        ZStack {

            Image("background")
                .resizable()
                .ignoresSafeArea()

            VStack {

                // 🔹 Top Bar
                HStack {

                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.white)
                    }

                    Spacer()

                    Button {
                        viewModel.isEditing.toggle()
                    } label: {
                        Image(systemName: viewModel.isEditing ? "checkmark" : "square.and.pencil")
                            .foregroundColor(.white)
                            .font(.title3)
                    }
                }
                .padding()

                Text("Your Trip Places")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)

                Text("These are the places you've selected for your trip")
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.bottom, 20)

                List {
                    ForEach(viewModel.selectedPlaces) { place in
                        Text(place.name)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(height: 80)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(25)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                    .onDelete { indexSet in
                        viewModel.selectedPlaces.remove(atOffsets: indexSet)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .padding(.horizontal, 10)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}
#Preview {
    NavigationStack {
        TripPlacesView(viewModel: {
            let vm = TripViewModel()
            vm.selectedPlaces = [
                TripPlace(name: "Diriyah", budget: "B3", interest: "History"),
                TripPlace(name: "Boulevard", budget: "B2", interest: "Entertainment"),
                TripPlace(name: "Local Coffee", budget: "B1", interest: "Coffee")
            ]
            return vm
        }())
    }
}
