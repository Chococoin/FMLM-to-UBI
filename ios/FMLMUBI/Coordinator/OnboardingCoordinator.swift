//
//  OnboardingCoordinator.swift
//  FMLMUBI
//
//  Created by German Lugo on 29/08/25.
//

import SwiftUI

enum OnboardingRoute: Hashable {
    case welcome
    case register
    case smsVerify(verificationId: String)
    case emailVerify(verificationId: String)
    case kycIntro
    case kycStatus(status: KycStatus)
    case home
}

final class OnboardingCoordinator: ObservableObject {
    @Published var path = NavigationPath()

    func goToWelcome() { path.append(OnboardingRoute.welcome) }
    func goToRegister() { path.append(OnboardingRoute.register) }
    func goToSmsVerify(_ id: String) { path.append(OnboardingRoute.smsVerify(verificationId: id)) }
    func goToEmailVerify(_ id: String) { path.append(OnboardingRoute.emailVerify(verificationId: id)) }
    func goToKycIntro() { path.append(OnboardingRoute.kycIntro) }
    func goToKycStatus(_ s: KycStatus) { path.append(OnboardingRoute.kycStatus(status: s)) }
    func goToHome() { path.append(OnboardingRoute.home) }

    func resetToRoot() { path = NavigationPath() }
}
