//
//  ProfileView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 18/04/25.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(GameManager.self) private var game
    @Environment(UserProfile.self) private var user

    @State private var isPhotoPickerPresented = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var minY: Int = 150

    var body: some View {
        List {
            GeometryReader { geo in
                let currentMinY = geo.frame(in: .global).minY

                HStack() {
                    Spacer()
                    VStack {
                        if let userPhoto = user.photo, let uiImage = UIImage(data: userPhoto) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped(antialiased: true)
                                .clipShape(Circle())
                                .onTapGesture {
                                    isPhotoPickerPresented = true
                                }
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundStyle(.tint)
                                .onTapGesture {
                                    isPhotoPickerPresented = true
                                }
                        }
                        Text(user.name)
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                        Text("Level: \(user.level)")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                        Spacer()
                    }
                    Spacer()
                }
                .onChange(of: currentMinY) { _, _ in
                    withAnimation(.smooth(duration: 0.25)) {
                        minY = Int(currentMinY)
                    }
                }
            }
            .frame(height: 170)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            Section {
                NavigationLink("Conquistas") {
                    AchievementView()
                }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))
            }

            Section {
                NavigationLink("Informações pessoais") {
                    UserInfoView()
                }
                NavigationLink("Estatísticas") {
                    StatisticsView()
                }
            }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(OrhadiTheme.getBGColor(for: colorScheme))
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(user.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .opacity(minY < -50 ? 1 : 0)
            }
        }
        .toolbarBackground(OrhadiTheme.getBGColor(for: colorScheme), for: .navigationBar)
        .photosPicker(isPresented: $isPhotoPickerPresented, selection: $selectedItem, matching: .images, photoLibrary: .shared())
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                    let size = CGSize(width: 80, height: 80)
                    if let resized = resizeImageAspectFill(data, targetSize: size) {
                        user.photo = resized
                    } else {
                        user.photo = data
                    }
                }
            }
        }
    }
}

#Preview("ProfileView") {
    NavigationStack {
        ProfileView()
            .environment(UserProfile())
            .environment(GameManager(context: SampleData.shared.context))
    }
}

struct StatisticsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(GameManager.self) private var game
    @Environment(UserProfile.self) private var user

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Level")
                    Spacer()
                    Text("\(user.level)")
                        .foregroundStyle(Color.secondary)
                }
                HStack {
                    Text("XP")
                    Spacer()
                    Text("\(user.xp)/\(game.xpRequired(for: user.level))")
                        .foregroundStyle(Color.secondary)
                }
                HStack {
                    Text("Tempo estudado")
                    Spacer()
                    Text(formatTime(user.timeStudied))
                        .foregroundStyle(Color.secondary)
                }
                HStack {
                    Text("Tarefas completadas")
                    Spacer()
                    Text("\(user.completedToDos)")
                        .foregroundStyle(Color.secondary)
                }
            }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))
        }
        .navigationTitle("Estatísticas")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(OrhadiTheme.getBGColor(for: colorScheme))
    }
}

struct UserInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
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
            }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))
        }
        .navigationTitle("Informações pessoais")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(OrhadiTheme.getBGColor(for: colorScheme))
    }
}

struct UserNameEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

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
            }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))
        }
        .navigationTitle("Nome")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(OrhadiTheme.getBGColor(for: colorScheme))
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
