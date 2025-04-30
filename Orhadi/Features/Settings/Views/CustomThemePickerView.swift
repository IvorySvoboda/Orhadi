//
//  CustomThemePickerView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 25/04/25.
//

import SwiftUI

struct CustomThemePickerView: View {
    @Environment(Settings.self) private var settings

    // MARK: - Views

    var body: some View {
        NavigationLink {
            CustomThemePicker()
        } label: {
            HStack {
                themeIcon
                Text("Tema")
                Spacer()
                Text(settings.theme.name)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var themeIcon: some View {
        ZStack {
            Image(systemName: "circle.righthalf.filled")
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundStyle(Color.accentColor)
                .overlay(
                    Image(systemName: "circle.lefthalf.filled")
                        .resizable()
                        .frame(width: 13, height: 13)
                        .foregroundStyle(Color.accentColor)
                        .background(
                            Color.orhadiBG
                                .frame(width: 12, height: 12)
                                .clipShape(Circle())
                        )
                )
        }.padding(.trailing, 10)
    }
}

struct CustomThemePicker: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(Settings.self) private var settings

    var body: some View {
        List {
            Section {
                ForEach(Theme.allCases, id: \.self) { theme in
                    Button {
                        settings.theme = theme
                        dismiss()
                    } label: {
                        HStack {
                            Text(theme.name)
                            Spacer()
                            if settings.theme == theme {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }.tint(colorScheme == .dark ? .white : .black)
                }
            }
            .listRowBackground(Color.orhadiSecondaryBG)
        }
        .orhadiListStyle()
        .navigationTitle("Tema")
        .navigationBarTitleDisplayMode(.inline)
    }
}
