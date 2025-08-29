//
//  RegisterView.swift
//  FMLMUBI
//
//  Created by German Lugo on 29/08/25.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var vm: OnboardingViewModel
    @EnvironmentObject var coordinator: OnboardingCoordinator

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = "+34"
    @State private var country = "ES"
    @State private var accept = false

    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        Form {
            Section("Datos personales") {
                TextField("Nombre", text: $firstName)
                TextField("Apellido", text: $lastName)
                TextField("E-mail", text: $email)
                    .keyboardType(.emailAddress)
                TextField("Teléfono (+E.164)", text: $phone)
                    .keyboardType(.phonePad)
                TextField("País (ISO)", text: $country)
            }
            Section {
                Toggle("Acepto Términos y Privacidad", isOn: $accept)
            }
            Section {
                Button {
                    Task { await submit() }
                } label: {
                    if isSubmitting { ProgressView() } else { Text("Registrar") }
                }
                .disabled(!canSubmit || isSubmitting)
            }
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) { showAlert = false }
        } message: {
            Text(alertMessage)
        }
    }

    var canSubmit: Bool {
        !firstName.isEmpty && !lastName.isEmpty && email.contains("@") && phone.hasPrefix("+") && accept
    }

    private func submit() async {
        isSubmitting = true
        defer { isSubmitting = false }
        do {
            try await vm.register(first: firstName, last: lastName, email: email, phoneE164: phone, country: country, accept: accept)
            guard let id = vm.verificationId else { return }
            coordinator.goToSmsVerify(id)
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }
}
