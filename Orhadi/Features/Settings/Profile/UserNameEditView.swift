//
//  UserNameEditView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 26/04/25.
//

import SwiftUI

struct UserNameEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(OrhadiTheme.self) private var theme

    @Bindable var user: UserProfile

    @State private var userName: String

    init(user: UserProfile) {
        self.user = user
        _userName = State(initialValue: user.name)
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Nome")
                        .frame(width: 50, alignment: .leading)
                    TextField("Obrigatório", text: $userName)
                        .autocorrectionDisabled()
                }
            }.listRowBackground(theme.secondaryBGColor())
        }
        .modifier(DefaultList())
        .navigationTitle("Nome")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Concluído") {
                    user.name = userName
                    dismiss()
                }.disabled(userName == user.name || userName.isEmpty)
            }
        }
    }
}
