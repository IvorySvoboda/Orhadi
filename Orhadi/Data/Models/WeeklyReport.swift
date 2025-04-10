//
//  WeeklyReport.swift
//  Orhadi
//
//  Created by Zyvoxi . on 08/04/25.
//

import Foundation
import SwiftData

@Model
final class WeeklyReport {

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
                .init(day: "Dom.", totalStudiedHour: 1.5),
                .init(day: "Seg.", totalStudiedHour: 0.5),
                .init(day: "Ter.", totalStudiedHour: 1),
                .init(day: "Qua.", totalStudiedHour: 0.5),
                .init(day: "Qui.", totalStudiedHour: 2),
                .init(day: "Sex.", totalStudiedHour: 2),
                .init(day: "Sáb.", totalStudiedHour: 1),
            ],
            mssByDayChartData: [
                .init(day: "Dom.", subject: "Biologia", totalStudiedHour: 0.5),
                .init(day: "Seg.", subject: "Biologia", totalStudiedHour: 0.5),
                .init(day: "Ter.", subject: "Português", totalStudiedHour: 1),
                .init(day: "Qua.", subject: "Inglês", totalStudiedHour: 0.5),
                .init(day: "Qui.", subject: "Filosofia", totalStudiedHour: 2),
                .init(day: "Sex.", subject: "Física", totalStudiedHour: 2),
                .init(day: "Sáb.", subject: "Redação", totalStudiedHour: 1),
            ],
            tssByDayChartData: [
                .init(day: "Dom.", totalSubjectsStudied: 1),
                .init(day: "Seg.", totalSubjectsStudied: 2),
                .init(day: "Ter.", totalSubjectsStudied: 1),
                .init(day: "Qua.", totalSubjectsStudied: 3),
                .init(day: "Qui.", totalSubjectsStudied: 2),
                .init(day: "Sex.", totalSubjectsStudied: 2),
                .init(day: "Sáb.", totalSubjectsStudied: 3),
            ]
        )
    ]

}

@Model
final class StudiedHoursChartData {
    var day: String
    var totalStudiedHour: Double

    init(day: String, totalStudiedHour: Double) {
        self.day = day
        self.totalStudiedHour = totalStudiedHour
    }
}

@Model
final class MSSByDayChartData {
    var day: String
    var subject: String
    var totalStudiedHour: Double

    init(day: String, subject: String, totalStudiedHour: Double) {
        self.day = day
        self.subject = subject
        self.totalStudiedHour = totalStudiedHour
    }
}

@Model
final class TSSByDayChartData {
    var day: String
    var totalSubjectsStudied: Double

    init(day: String, totalSubjectsStudied: Double) {
        self.day = day
        self.totalSubjectsStudied = totalSubjectsStudied
    }
}
