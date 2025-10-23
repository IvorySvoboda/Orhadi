//
//  SessionItem.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 22/10/25.
//

import Foundation

struct SessionItem: Identifiable {
    let id = UUID()
    let name: String
    var endTime: Date
    let isBreak: Bool
    let study: SRStudy?
}
