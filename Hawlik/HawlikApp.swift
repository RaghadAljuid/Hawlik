//
//  HawlikApp.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 16/08/1447 AH.
//

import SwiftUI

@main
struct HawlikApp: App {
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()

                if showSplash {
                    // شاشة السبلّاش
                    ZStack {
                        Color.white.ignoresSafeArea()

                        Image("SplashImage")
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                            .clipped()
                            .offset(y: -10) // ارفع أو نزل بتغيير القيمة          // يقص الزوائد لو نسبة الأبعاد مختلفة
                    }
                    .transition(.opacity)
                }
            }
            .onAppear {
                // مدة الظهور (مثلاً 2 ثانية)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        showSplash = false
                    }
                }
            }
        }
    }
}
