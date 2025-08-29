import SwiftUI

struct HomeView: View {
    @EnvironmentObject var vm: OnboardingViewModel

    var body: some View {
        List {
            Section("Estado") {
                Label(kycLine(), systemImage: kycIcon())

                if vm.walletLinked, let addr = vm.walletAddress {
                    Label("Wallet: conectada", systemImage: "wallet.pass")
                    Text(addrShort(addr))
                        .font(.footnote.monospaced())
                        .foregroundStyle(.secondary)
                } else {
                    Label("Wallet: desconectada (MetaMask)", systemImage: "wallet.pass")
                }
            }

            Section {
                #if targetEnvironment(simulator)
                if vm.walletLinked {
                    Button("Desconectar wallet (sim)") {
                        vm.mockDisconnectWallet()
                    }
                } else {
                    Button("Conectar con MetaMask (sim)") {
                        vm.mockConnectWallet()
                    }
                }
                #else
                Button("Conectar con MetaMask") {
                    // Aquí irá el flujo real con MetaMask SDK (cuando tengamos iPhone)
                }
                #endif

                Button("Reclamar UBI") { /* TODO */ }
                    .disabled(!vm.walletLinked)
            }
            #if targetEnvironment(simulator)
            Section("Dev") {
                Button("KYC → pending")  { vm.setKyc(.pending) }
                Button("KYC → approved") { vm.setKyc(.approved) }
                Button("KYC → rejected") { vm.setKyc(.rejected) }
            }
            #endif
        }
        .navigationTitle("Inicio")
    }

    private func addrShort(_ a: String) -> String {
        guard a.count > 12 else { return a }
        let start = a.prefix(6)
        let end = a.suffix(4)
        return "\(start)…\(end)"
    }

    private func kycLine() -> String {
        switch vm.kycStatus {
        case .pending: return "KYC: pendiente"
        case .approved: return "KYC: aprobado"
        case .rejected: return "KYC: rechazado"
        case .requiredNotAvailable: return "KYC: no disponible en tu país"
        }
    }

    private func kycIcon() -> String {
        switch vm.kycStatus {
        case .pending: return "hourglass"
        case .approved: return "checkmark.seal"
        case .rejected: return "xmark.seal"
        case .requiredNotAvailable: return "exclamationmark.triangle"
        }
    }
}
