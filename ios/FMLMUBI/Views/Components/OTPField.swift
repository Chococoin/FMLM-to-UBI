//
//  OTPField.swift
//  FMLMUBI
//
//  Created by German Lugo on 29/08/25.
//

import SwiftUI

struct OTPField: View {
    @Binding var code: String
    let digits: Int
    let isEnabled: Bool
    @FocusState private var focused: Bool

    var body: some View {
        ZStack {
            TextField("", text: Binding(
                get: { code },
                set: { new in
                    let filtered = new.filter(\.isNumber)
                    code = String(filtered.prefix(digits))
                })
            )
            .keyboardType(.numberPad)
            .textContentType(.oneTimeCode)
            .focused($focused)
            .frame(width: 0, height: 0)
            .opacity(0.01)
            .disabled(!isEnabled)

            HStack(spacing: 12) {
                ForEach(0..<digits, id: \.self) { idx in
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.secondary)
                            .frame(width: 44, height: 52)
                        Text(charAt(idx))
                            .font(.title2.monospaced())
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if isEnabled { focused = true }
            }
        }
        .onAppear { if isEnabled { focused = true } }
    }

    private func charAt(_ index: Int) -> String {
        guard index < code.count else { return "" }
        let i = code.index(code.startIndex, offsetBy: index)
        return String(code[i])
    }
}
