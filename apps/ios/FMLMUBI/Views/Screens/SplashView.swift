//
//  SplashView.swift
//  FMLMUBI
//
//  Created by German Lugo on 29/08/25.
//

import SwiftUI

struct SplashView: View {
    @EnvironmentObject var coordinator: OnboardingCoordinator

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "globe")
                    .font(.system(size: 64))
                Text("FMLM → UBI")
                    .font(.title)
                Text("Slogan del proyecto (mock)")
                    .foregroundStyle(.secondary)
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            coordinator.goToWelcome()
        }
    }
}
