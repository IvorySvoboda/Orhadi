//
//  SRView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 31/03/25.
//

import SwiftData
import SwiftUI

struct SRView: View {
    @State private var vm = ViewModel(dataManager: .shared)

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {
                WeekdayPickerBar(selectedDay: $vm.selectedDay)
                    .opacity(vm.showSelectedWeekday ? 0 : 1)

                ForEach(vm.filteredStudies, content: SRRow.init)
            }
            .environment(vm)
            .listStyle(.plain)
            .navigationTitle("Study Routine")
            .onScrollGeometryChange(for: CGFloat.self, of: { geo in
                geo.contentOffset.y
            }, action: { _, scrollOffset in
                vm.handleScrollGeoChange(scrollOffset)
            })
            .overlay { emptyStateOverlay }
            .toolbar { toolbarComponents }
            .navigationDestination(isPresented: $vm.navigateToStudyingView) {
                StudyingView(studies: vm.studiesToStudy)
            }
            .sheet(item: $vm.studyToAdd) { study in
                SRSheetView(study: study, isNew: true)
                    .interactiveDismissDisabled()
            }
            .sheet(item: $vm.studyToEdit) { study in
                SRSheetView(study: study, isNew: false)
                    .interactiveDismissDisabled()
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarComponents: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            ZStack {
                Text("Study Routine")
                    .font(.headline)
                    .frame(height: 30)
                    .opacity(vm.showTitle ? 1 : 0)
                    .blur(radius: vm.showTitle ? 0 : 3)
                    .offset(y: vm.showSelectedWeekday ? -8 : vm.showTitle ? 0 : 14)

                Text(vm.toolbarTitle)
                    .foregroundStyle(.tint)
                    .font(.caption)
                    .frame(height: 30)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(vm.showSelectedWeekday ? 1 : 0)
                    .blur(radius: vm.showSelectedWeekday ? 0 : 3)
                    .offset(y: vm.showSelectedWeekday ? 8 : 14)
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button("Add", systemImage: "plus") {
                vm.studyToAdd = SRStudy(studyDay: Calendar.current.date(
                    bySetting: .weekday,
                    value: vm.selectedDay,
                    of: Date(timeIntervalSince1970: 0))!)
            }.tint(.accentColor)
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button("Start Studying", systemImage: "play.fill") {
                if vm.canStartStudying {
                    vm.studiesToStudy = vm.studiesForTheSelectedDay
                    vm.navigateToStudyingView = true
                }
            }
            .tint(.accentColor)
            .disabled(!vm.canStartStudying)
        }
    }

    // MARK: - Overlay

    @ViewBuilder
    private var emptyStateOverlay: some View {
        if vm.filteredStudies.isEmpty, !vm.hideOverlay {
            ContentUnavailableView {
                Label("Nothing to Study", systemImage: "graduationcap")
            } description: {
                Text("Nothing to study today. How about taking a little time to rest?")
            }
        }
    }
}
