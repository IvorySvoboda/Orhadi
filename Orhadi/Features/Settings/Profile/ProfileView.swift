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
    @Environment(OrhadiTheme.self) private var theme

    @State private var isPhotoPickerPresented = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var minY: Int = 150

    var body: some View {
        List {
            HStack() {
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
                }
            }
            .compositingGroup()
            .drawingGroup()
            .frame(maxWidth: .infinity, maxHeight: 170, alignment: .center)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onChange(of: geo.frame(in: .global).minY) { _, newY in
                            withAnimation(.smooth(duration: 0.25)) {
                                minY = Int(newY)
                            }
                        }
                }
            )

            Section {
                NavigationLink {
                    AchievementView()
                } label: {
                    Label("Conquistas", systemImage: "medal.star.fill")
                }
            }.listRowBackground(theme.secondaryBGColor())

            Section {
                NavigationLink {
                    UserInfoView()
                } label: {
                    Label("Informações pessoais", systemImage: "person.fill")
                }
                NavigationLink {
                    StatisticsView()
                } label: {
                    Label("Estatísticas", systemImage: "chart.bar.xaxis")
                }
            }.listRowBackground(theme.secondaryBGColor())
        }
        .modifier(DefaultList())
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(user.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .opacity(minY < -50 ? 1 : 0)
            }
        }
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
