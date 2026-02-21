//
//  ToDosView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 26/03/25.
//

import SwiftData
import SwiftUI
import WidgetKit

struct ToDosView: View {
    @State private var vm = ViewModel(dataManager: .shared)

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {
                ToDosSectionPickerBar(selectedSection: $vm.selectedSection)
                    .opacity(vm.showSelectedSection ? 0 : 1)

                ForEach(vm.visibleToDos, content: ToDoRow.init)
            }
            .environment(vm)
            .listStyle(.plain)
            .navigationTitle("To-Do")
            .onScrollGeometryChange(for: CGFloat.self, of: { geo in
                geo.contentOffset.y
            }, action: { _, scrollOffset in
                vm.handleScrollGeoChange(scrollOffset)
            })
            .toolbar { toolbarComponents }
            .overlay { emptyStateOverlay }
            .sheet(item: $vm.todoToAdd) { todo in
                ToDoSheetView(todo: todo, isNew: true)
                    .interactiveDismissDisabled()
            }
            .sheet(item: $vm.todoToEdit) { todo in
                ToDoSheetView(todo: todo, isNew: false)
                    .interactiveDismissDisabled()
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarComponents: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            ZStack {
                Text("To-Do")
                    .font(.headline)
                    .frame(height: 30)
                    .opacity(vm.showTitle ? 1 : 0)
                    .blur(radius: vm.showTitle ? 0 : 3)
                    .offset(y: vm.showSelectedSection ? -8 : vm.showTitle ? 0 : 14)

                Text(vm.selectedSection.string)
                    .textCase(.uppercase)
                    .foregroundStyle(.tint)
                    .font(.caption)
                    .frame(height: 30)
                    .opacity(vm.showSelectedSection ? 1 : 0)
                    .blur(radius: vm.showSelectedSection ? 0 : 3)
                    .offset(y: vm.showSelectedSection ? 8 : 14)
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button("Add", systemImage: "plus") {
                vm.todoToAdd = ToDo()
            }.tint(.accentColor)
        }
    }

    // MARK: - Overlay

    @ViewBuilder
    private var emptyStateOverlay: some View {
        if vm.visibleToDos.isEmpty, !vm.hideOverlay {
            ContentUnavailableView {
                Label(
                    vm.selectedSection == .pending ? "No Pending To-Dos" : "No Completed To-Dos",
                    systemImage: "list.bullet.clipboard")
            } description: {
                Text(
                    vm.selectedSection == .pending
                    ? "Add new To-Dos to start getting organized."
                    : "Complete To-Dos to see them here."
                )
            } actions: {
                Button("Add To-Do") {
                    vm.todoToAdd = ToDo()
                }
                .buttonStyle(.borderedProminent)
                .foregroundStyle(Color.orhadiBG)
            }
        }
    }
}
