//
//  UserInfoView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 26/04/25.
//

import SwiftUI

struct UserInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(UserProfile.self) private var user

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
            }.listRowBackground(Color.orhadiSecondaryBG)
        }
        .orhadiListStyle()
        .navigationTitle("Informações pessoais")
        .navigationBarTitleDisplayMode(.inline)
    }
}
