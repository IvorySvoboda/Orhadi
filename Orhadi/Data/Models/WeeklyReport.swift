//
//  WeeklyReport.swift
//  Orhadi
//
//  Created by Zyvoxi . on 08/04/25.
//

import Foundation
import SwiftData

enum WeeklyReportSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [WeeklyReport.self]
    }

    @Model
    class WeeklyReport {

        var id: String = UUID().uuidString
        var start: Date
        var end: Date
        var studiedHoursChartData: [StudiedHoursChartData]
        var mssByDayChartData: [MSSByDayChartData]
        var tssByDayChartData: [TSSByDayChartData]

        init(
            id: String = UUID().uuidString,
            start: Date,
            end: Date,
            studiedHoursChartData: [StudiedHoursChartData],
            mssByDayChartData: [MSSByDayChartData],
            tssByDayChartData: [TSSByDayChartData]
        ) {
            self.id = id
            self.start = start
            self.end = end
            self.studiedHoursChartData = studiedHoursChartData
            self.mssByDayChartData = mssByDayChartData
            self.tssByDayChartData = tssByDayChartData
        }

        static let sampleData = [
            WeeklyReport(
                start: Date(),
                end: Date(),
                studiedHoursChartData: [
                    .init(day: 1, totalStudiedHour: 1.5),
                    .init(day: 2, totalStudiedHour: 0.5),
                    .init(day: 3, totalStudiedHour: 1),
                    .init(day: 4, totalStudiedHour: 0.5),
                    .init(day: 5, totalStudiedHour: 2),
                    .init(day: 6, totalStudiedHour: 2),
                    .init(day: 7, totalStudiedHour: 1),
                ],
                mssByDayChartData: [
                    .init(day: 1, subject: "Biologia", totalStudiedHour: 0.5),
                    .init(day: 2, subject: "Biologia", totalStudiedHour: 0.5),
                    .init(day: 3, subject: "Português", totalStudiedHour: 1),
                    .init(day: 4, subject: "Inglês", totalStudiedHour: 0.5),
                    .init(day: 5, subject: "Filosofia", totalStudiedHour: 2),
                    .init(day: 6, subject: "Física", totalStudiedHour: 2),
                    .init(day: 7, subject: "Redação", totalStudiedHour: 1),
                ],
                tssByDayChartData: [
                    .init(day: 1, totalSubjectsStudied: 1),
                    .init(day: 2, totalSubjectsStudied: 2),
                    .init(day: 3, totalSubjectsStudied: 1),
                    .init(day: 4, totalSubjectsStudied: 3),
                    .init(day: 5, totalSubjectsStudied: 2),
                    .init(day: 6, totalSubjectsStudied: 2),
                    .init(day: 7, totalSubjectsStudied: 3),
                ]
            )
        ]
    }
}

struct StudiedHoursChartData: Identifiable, Codable {
    var day: Int
    var totalStudiedHour: Double
    var id = UUID()
}

struct MSSByDayChartData: Identifiable, Codable {
    var day: Int
    var subject: String
    var totalStudiedHour: Double
    var id = UUID()
}

struct TSSByDayChartData: Identifiable, Codable {
    var day: Int
    var totalSubjectsStudied: Double
    var id = UUID()
}
