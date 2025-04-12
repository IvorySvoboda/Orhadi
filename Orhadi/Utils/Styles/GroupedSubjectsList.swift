//
//  GroupedSubjectsList.swift
//  Orhadi
//
//  Created by Zyvoxi . on 05/04/25.
//

import SwiftUI

struct GroupedSubjectsList<Subject: Identifiable>: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedDay: Int = Calendar.current.component(.weekday, from: Date())

    let subjects: [Subject]
    let dateExtractor: (Subject) -> Date
    let cell: (Subject) -> AnyView

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { proxy in
                HStack(spacing: 12) {
                    ForEach(1...7, id: \.self) { index in
                        let name = Calendar.current.weekdaySymbols[index - 1]
                        Text(index == selectedDay ? name.capitalized : name.prefix(3).capitalized)
                            .font(.callout)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                Capsule()
                                    .fill(index == selectedDay ? Color.accentColor : OrhadiTheme.getSecondaryBGColor(for: colorScheme))
                            )
                            .foregroundColor(index == selectedDay ? OrhadiTheme.getBGColor(for: colorScheme) : .primary)
                            .onTapGesture {
                                withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8)) {
                                    selectedDay = index
                                    proxy.scrollTo(index, anchor: .center)
                                }
                            }
                            .id(index)
                    }
                }
                .padding(.horizontal)
                .onAppear {
                    withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8)) {
                        proxy.scrollTo(selectedDay, anchor: .center)
                    }
                }
            }
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .scrollTargetLayout()
        .padding(.vertical, 8)

        let filteredSubjects = filteredSubjects(for: selectedDay)

        ForEach(filteredSubjects) { subject in
            cell(subject)
        }
    }

    private func filteredSubjects(for weekdayIndex: Int) -> [Subject] {
        subjects.filter {
            Calendar.current.component(.weekday, from: dateExtractor($0)) == weekdayIndex
        }
    }
}
