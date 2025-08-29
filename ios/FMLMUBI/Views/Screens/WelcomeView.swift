//
//  WelcomeView.swift
//  FMLMUBI
//
//  Created by German Lugo on 29/08/25.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var coordinator: OnboardingCoordinator

    var body: some View {
        VStack(spacing: 24) {
            Text("Bienvenido a FMLM → UBI")
                .font(.largeTitle.bold())
            Text("Una economía global más justa comienza contigo.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("Comenzar") {
                coordinator.goToRegister()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
