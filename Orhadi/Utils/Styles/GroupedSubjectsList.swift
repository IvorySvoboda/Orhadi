//
//  GroupedSubjectsList.swift
//  Orhadi
//
//  Created by Zyvoxi . on 05/04/25.
//

import SwiftUI

struct GroupedSubjectsList<Subject: Identifiable>: View {
    let subjects: [Subject]
    let dateExtractor: (Subject) -> Date
    let cell: (Subject) -> AnyView

    var body: some View {
        let grouped = Dictionary(grouping: subjects) { item in
            Calendar.current.component(.weekday, from: dateExtractor(item))
        }

        ForEach(Calendar.weekdays.sorted(by: { $0.key < $1.key }), id: \.key) { key, weekday in
            if let daySubjects = grouped[key] {
                Section {
                    ForEach(daySubjects) { subject in
                        cell(subject)
                    }
                } header: {
                    SectionHeader(text: weekday)
                }
            }
        }
    }
}
