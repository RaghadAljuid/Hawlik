//
//  TripPlanningFlowView.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 27/08/1447 AH.
//
import SwiftUI

struct TripPlanningFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = TripViewModel()

    var body: some View {
        NavigationStack {
            Norah1View(viewModel: vm, onClose: { dismiss() })
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
