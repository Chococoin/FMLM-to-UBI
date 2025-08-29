//
//  FMLMUBIApp.swift
//  FMLMUBI
//
//  Created by German Lugo on 29/08/25.
//

import SwiftUI

@main
struct FMLMUBIApp: App {
    @StateObject private var coordinator = OnboardingCoordinator()
    @StateObject private var viewModel = OnboardingViewModel(auth: MockAuthService())

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(coordinator)
                .environmentObject(viewModel)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var coordinator: OnboardingCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            SplashView()
                .navigationDestination(for: OnboardingRoute.self) { route in
                    switch route {
                    case .welcome:
                        WelcomeView()
                    case .register:
                        RegisterView()
                    case .smsVerify(let verificationId):
                        SmsVerifyView(verificationId: verificationId)
                    case .emailVerify(let verificationId):
                        EmailVerifyView(verificationId: verificationId)
                    case .kycIntro:
                        KycIntroView()
                    case .kycStatus(let status):
                        KycStatusView(status: status)
                    case .home:
                        HomeView()
                    }
                }
        }
    }
}
