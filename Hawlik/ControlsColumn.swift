//
//  ControlsColumn.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 20/08/1447 AH.
//
import SwiftUI

struct ControlsColumn: View {
    var onMyLocation: () -> Void
    var onZoomIn: () -> Void
    var onZoomOut: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Button(action: onMyLocation) {
                Image(systemName: "location.fill")
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }

            Button(action: onZoomIn) {
                Image(systemName: "plus")
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }

            Button(action: onZoomOut) {
                Image(systemName: "minus")
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
        }
        .padding(.top, 10)
    }
}
