//
//  CustomThemePickerView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 25/04/25.
//

import SwiftUI

struct CustomThemePickerView: View {
    @Environment(OrhadiTheme.self) private var theme
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
                Text(themeName(for: settings.theme))
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
                            theme.bgColor()
                                .clipShape(Circle())
                        )
                )
        }.padding(.trailing, 10)
    }

    // MARK: - Functions

    private func themeName(for theme: Theme) -> String {
        switch theme {
        case .auto: return String(localized: "Auto")
        case .dark: return String(localized: "Escuro")
        case .light: return String(localized: "Claro")
        }
    }
}

struct CustomThemePicker: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(OrhadiTheme.self) private var theme
    @Environment(Settings.self) private var settings

    var body: some View {
        List {
            Section {
                Button {
                    settings.theme = .light
                    dismiss()
                } label: {
                    HStack {
                        Text("Claro")
                            .font(.headline)
                        Spacer()
                        if settings.theme == .light {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }.tint(colorScheme == .dark ? .white : .black)

                Button {
                    settings.theme = .dark
                    dismiss()
                } label: {
                    HStack {
                        Text("Escuro")
                            .font(.headline)
                        Spacer()
                        if settings.theme == .dark {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }.tint(colorScheme == .dark ? .white : .black)

                Button {
                    settings.theme = .auto
                    dismiss()
                } label: {
                    HStack {
                        Text("Auto")
                            .font(.headline)
                        Spacer()
                        if settings.theme == .auto {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }.tint(colorScheme == .dark ? .white : .black)
            }
            .listRowBackground(theme.secondaryBGColor())
        }
        .modifier(DefaultList())
        .navigationTitle("Tema")
        .navigationBarTitleDisplayMode(.inline)
    }
}
