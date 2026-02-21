//
//  Subjects.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 26/03/25.
//

import SwiftData
import SwiftUI
import WidgetKit

struct SubjectsView: View {
    @Namespace private var animation
    @State private var vm = ViewModel(dataManager: .shared)

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {
                WeekdayPickerBar(selectedDay: $vm.selectedDay)
                    .opacity(vm.showSelectedWeekday ? 0 : 1)

                ForEach(vm.filteredSubjects, content: SubjectRow.init)
            }
            .environment(vm)
            .listStyle(.plain)
            .navigationTitle("Subjects")
            .onScrollGeometryChange(for: CGFloat.self, of: { geo in
                geo.contentOffset.y
            }, action: { _, scrollOffset in
                vm.handleScrollGeoChange(scrollOffset)
            })
            .toolbar { toolbarComponents }
            .overlay { emptyStateOverlay }
            .sheet(item: $vm.subjectToAdd) { subject in
                SubjectSheetView(subject: subject, isNew: true)
                    .interactiveDismissDisabled()
            }
            .sheet(item: $vm.subjectToEdit) { subject in
                SubjectSheetView(subject: subject, isNew: false)
                    .interactiveDismissDisabled()
            }
            .sheet(isPresented: $vm.showAddOptionsSheet) {
                SubjectsAddOptionsSheet(subjectToAdd: $vm.subjectToAdd, selectedDay: vm.selectedDay)
                    .navigationTransition(.zoom(sourceID: "Add", in: animation))
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarComponents: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            ZStack {
                Text("Subjects")
                    .font(.headline)
                    .frame(height: 30)
                    .opacity(vm.showTitle ? 1 : 0)
                    .blur(radius: vm.showTitle ? 0 : 3)
                    .offset(y: vm.showSelectedWeekday ? -8 : vm.showTitle ? 0 : 14)

                Text(vm.toolbarTitle)
                    .foregroundStyle(.tint)
                    .font(.caption)
                    .frame(height: 30)
                    .opacity(vm.showSelectedWeekday ? 1 : 0)
                    .blur(radius: vm.showSelectedWeekday ? 0 : 3)
                    .offset(y: vm.showSelectedWeekday ? 8 : 14)
            }
        }

        if #available(iOS 26, *) {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add", systemImage: "plus") {
                    vm.showAddOptionsSheet.toggle()
                }.tint(.accentColor)
            }.matchedTransitionSource(id: "Add", in: animation)
        } else {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add", systemImage: "plus") {
                    vm.showAddOptionsSheet.toggle()
                }.tint(.accentColor)
            }
        }
    }

    // MARK: - Overlay

    @ViewBuilder
    private var emptyStateOverlay: some View {
        if vm.filteredSubjects.isEmpty, !vm.hideOverlay {
            ContentUnavailableView {
                Label("No Subjects", systemImage: "book")
            } description: {
                Text("No subjects today. How about taking some time to rest a little?")
            }
        }
    }
}
