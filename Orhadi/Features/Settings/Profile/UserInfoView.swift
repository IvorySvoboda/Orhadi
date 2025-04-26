//
//  UserInfoView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 26/04/25.
//

import SwiftUI

struct UserInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(UserProfile.self) private var user
    @Environment(OrhadiTheme.self) private var theme

    var body: some View {
        List {
            Section {
                NavigationLink {
                    UserNameEditView(user: user)
                } label: {
                    HStack {
                        Text("Nome")
                        Spacer()
                        Text(user.name)
                            .foregroundStyle(Color.secondary)
                    }
                }
            }.listRowBackground(theme.secondaryBGColor())
        }
        .modifier(DefaultList())
        .navigationTitle("Informações pessoais")
        .navigationBarTitleDisplayMode(.inline)
    }
}
